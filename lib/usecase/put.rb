#!/usr/bin/ruby
	
module SafeDb

  # The <b>put use case</b> follows <b>open</b> and it adds secrets into an
  # <em>(encrypted at rest)</em> <b>envelope</b>. Put can be called many times
  # and when done, the <b>lock use case</b> can be called to commit all opened
  # secrets into the configured storage engines.
  #
  # Calling <em>put</em> <b>before</b> calling open or <b>after</b> calling lock
  # is not allowed and will result in an error.
  #
  # == Put Pre-Conditions
  #
  # When the put use case is called - the below conditions ring true.
  #
  # - the <b>folder path</b> ending in ../../my must exist
  # - a session id, filename and encryption key ( in workstation config )
  #
  # == Observable Value
  #
  # The observable value delivered by +put+ boils down to
  #
  # - a new <b>friends.xyz123abc.os.txt</b> file if this is the first put.
  # - a new group_name/key_name (like monica/surname) entry is added if required
  # - a secret value is added against the key or updated if it already exists
  # - a new session id and encryption key is generated and used to re-encrypt
  class Put < UseCase

    attr_writer :secret_id, :secret_value

    # Execute the act of putting a string key and string value pair into a
    # map at the chapter and verse location, overwriting if need be.
    def execute

      return unless ops_key_exists?
      master_db = BookIndex.read()

      return if unopened_envelope?( master_db )

      envelope_id = ENVELOPE_KEY_PREFIX + master_db[ ENV_PATH ]
      has_content = KeyApi.db_envelope_exists?( master_db[ envelope_id ] )

      # To get hold of the content we must either
      #
      #   a) unlock it using the breadcrumbs or
      #   b) start afresh with a new content db
      content_box = KeyStore.from_json( Lock.content_unlock( master_db[ envelope_id ] ) ) if has_content
      content_box = KeyStore.new() unless has_content
      content_hdr = create_header()

      # If no content envelope exists we need to place
      # an empty one inside the appdb content database.
      master_db[ envelope_id ] = {} unless has_content

      # This is the PUT use case so we append a
      #
      #   a) key for the new dictionary entry
      #   b) value for the new dictionary entry
      #
      # into the current content envelope and write
      # the envelope to the content filepath.
      crumbs_dict = master_db[ envelope_id ]
      content_box.create_entry( master_db[ KEY_PATH ], @secret_id, @secret_value )
      Lock.content_lock( crumbs_dict, content_box.to_json, content_hdr )

      # Three envelope crumbs namely the external ID, the
      # random iv and the crypt key are written afresh into
      # the master database.
      BookIndex.write( content_hdr, master_db )

      # Show the mini dictionary at the opened chapter and verse location
      Show.new.flow_of_events

    end


  end


end
