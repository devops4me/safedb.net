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
  #
  # == Example | Bill Clinton's Secrets
  #
  # In our fictitious example Bill Clinton uses safe to lock away the
  # names and dates of his lady friends.
  #
  #    $ safe init bill.clinton@example.com
  #    $ safe open my/friends
  #
  #    $ safe put monica/surname lewinsky
  #    $ safe put monica/from "April 1989"
  #    $ safe put monica/to "September 1994"
  #
  #    $ safe put hilary/surname clinton
  #    $ safe put hilary/from "January 1988"
  #    $ safe put hilary/to "Present Day"
  #
  #    $ safe lock
  #
  # Soon follow up use cases will be unveiled, enabling us to
  #
  # - <b>get</b>
  # - <b>read</b>
  # - <b>list</b>
  # - <b>look</b>
  # - <b>peep</b> and
  # - <b>peek</b>
  class Rename < UseCase


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
    #
    # == How to Pretty Print a Hash in JSON Format
    #
    # This pretty prints a Hash (dictionary) data structure in JSON format.
    #
    #    puts "---\n"
    #    puts JSON.pretty_generate( master_db )
    #    puts "---\n"
    #
    def execute

      return unless ops_key_exists?
      master_db = KeyApi.read_master_db()

      return if unopened_envelope?( master_db )

      envelope_id = ENVELOPE_KEY_PREFIX + master_db[ ENV_PATH ]
      has_content = KeyApi.db_envelope_exists?( master_db[ envelope_id ] )

      # --
      # -- To get hold of the content we must either
      # --
      # --   a) unlock it using the breadcrumbs or
      # --   b) start afresh with a new content db
      # --
      content_box = KeyStore.from_json( KeyApi.content_unlock( master_db[ envelope_id ] ) ) if has_content
      content_box = KeyStore.new() unless has_content
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
      KeyApi.content_lock( crumbs_dict, content_box.to_json, content_hdr )

      # --
      # -- Three envelope crumbs namely the external ID, the
      # -- random iv and the crypt key are written afresh into
      # -- the master database.
      # --
      KeyApi.write_master_db( content_hdr, master_db )
      print_put_success

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
