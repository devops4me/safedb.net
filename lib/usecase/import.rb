#!/usr/bin/ruby
	
module SafeDb

  # The <b>import use case</b> follows <b>open</b> and it pulls a file into an
  # <em>(encrypted at rest)</em> <b>envelope</b> while writing metadata about
  # the file into the opened tree dictionary position.
  #
  # == import and reimport commands
  #
  # - the import command expects a path parameter and errors if not recvd
  # - the reimport command is happy with either one or zero parameters
  #
  # If the reimport command has no parameters it expects that the opened path
  # already contains an imported file. It uses the import.path key to locate
  # the file.
  #
  # If the path parameter is given to reimport it uses it and also resets the
  # import.path key to reflect the path it was given.
  #
  # == garbage collect dangling files
  #
  # Like dangling envelopes - dangling files will pop up when re-imported.
  # These are handled by the garbage collection policy which can be to
  # remove immediately - remove on next login - remove after a time period
  # or to never remove (manual garbage collection).
  #
  class Import < UseCase

    attr_writer :secret_id, :secret_value

    # The <b>put use case</b> follows <b>open</b> and it adds secrets into an
    # <em>(encrypted at rest)</em> envelope. Put can be called many times to
    # add secrets. Finally the <b>lock use case</b> commits all opened secrets
    # into the configured storage engines.
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
    def execute

      return unless ops_key_exists?
      master_db = OpenKey::KeyApi.read_master_db()

      puts "---\n"
      puts "--- The Master Database (Before)\n"
      puts "---\n"
      puts JSON.pretty_generate( master_db )
      puts "---\n"

      return if unopened_envelope?( master_db )

      envelope_id = ENVELOPE_KEY_PREFIX + master_db[ ENV_PATH ]
      has_content = OpenKey::KeyApi.db_envelope_exists?( master_db[ envelope_id ] )

      # --
      # -- To get hold of the content we must either
      # --
      # --   a) unlock it using the breadcrumbs or
      # --   b) start afresh with a new content db
      # --
      content_box = OpenKey::KeyDb.from_json( OpenKey::KeyApi.content_unlock( master_db[ envelope_id ] ) ) if has_content
      content_box = OpenKey::KeyDb.new() unless has_content
      content_hdr = create_header()

      # --
      # -- If no content envelope exists we need to place
      # -- an empty one inside the appdb content database.
      # --
      master_db[ envelope_id ] = {} unless has_content

      # --
      # -- This is the PUT use case so we append a
      # --
      # --   a) key for the new dictionary entry
      # --   b) value for the new dictionary entry
      # --
      # -- into the current content envelope and write
      # -- the envelope to the content filepath.
      # --
      crumbs_dict = master_db[ envelope_id ]
      content_box.create_entry( master_db[ KEY_PATH ], @secret_id, @secret_value )
      OpenKey::KeyApi.content_lock( crumbs_dict, content_box.to_json, content_hdr )

      puts "---\n"
      puts "--- The Master Database (After)\n"
      puts "---\n"
      puts JSON.pretty_generate( master_db )
      puts "---\n"

      # --
      # -- Three envelope crumbs namely the external ID, the
      # -- random iv and the crypt key are written afreshinto
      # -- the master database.
      # --
      OpenKey::KeyApi.write_master_db( content_hdr, master_db )
      print_put_success

      return


# --->      secret_ids = @secret_id.split("/")
# --->      if ( envelope.has_key? secret_ids.first )
# --->        envelope[secret_ids.first][secret_ids.last] = @secret_value
# --->      else
# --->        envelope[secret_ids.first] = { secret_ids.last => @secret_value }
# --->      end

    end


    private


    def print_put_success

      puts ""
      puts "Success putting a key/value pair into the open envelope."
      puts "You can put more in and then close the envelope."
      puts ""
      puts "    #{COMMANDMENT} close"
      puts ""

    end


    # Perform pre-conditional validations in preparation to executing the main flow
    # of events for this use case. This method may throw the below exceptions.
    #
    # @raise [SafeDirNotConfigured] if the safe's url has not been configured
    # @raise [EmailAddrNotConfigured] if the email address has not been configured
    # @raise [StoreUrlNotConfigured] if the crypt store url is not configured
    def pre_validation


    end


  end


end
