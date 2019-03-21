#!/usr/bin/ruby

module SafeDb



  class KeyApi

=begin
    def self.setup_domain_keys( domain_name, domain_secret, content_header )

      # --
      # -- Get the breadcrumbs trail and
      # -- timestamp the moment.
      # --
      crumbs_db = get_crumbs_db_from_domain_name( domain_name )
      crumbs_db.set( APP_INSTANCE_SETUP_TIME, KeyNow.fetch() )

      # --
      # -- Create a new power key and lock the content with it.
      # -- Create a new inter key and lock the power key with it.
      # -- Leave the necessary breadcrumbs for regeneration.
      # --
      recycle_keys( domain_name, domain_secret, crumbs_db, content_header, get_virgin_content( domain_name ) )

    end
=end



    # At <b>the end</b> of a successful login the <b>old content crypt key</b> will
    # have been <b>re-acquired and discarded,</b> with a <b>fresh one created</b>and
    # put to work <b>protecting</b> the application's content.
    #
    # After reacquisitioning (but before discarding) the old crypt key, the app's
    # key-value database is <b>silently decrypted with it then immediately re-encrypted</b>
    # with the newly created (and locked down) crypt key.
    #
    # <b>Login Recycles 3 things</b>
    #
    # The three (3) things recycled by this login are
    #
    # - the human key (sourced by putting the secret text through two key derivation functions)
    # - the content crypt key (sourced from a random 48 byte sequence) 
    # - the content ciphertext (sourced by decrypting with the old and re-encrypting with the new)
    #
    # Remember that the content crypt key is itself encrypted by two key entities.
    #
    # <b>The Inter and Intra Session Crypt Keys</b>
    #
    # This <b>login use case</b> is the <b>only time</b> in the session that the
    # <b>human provided secret</b> is made available - hence the inter-session name.
    #
    # The intra session key is employed by use case calls on within (intra) the
    # session it was created within.
    #
    # <b>The Weakness of the Human Inter Sessionary Key</b>
    #
    # The weakest link in the human-sourced key is clearly the human. Yes it is
    # strengthened by key derivation functions with cost parameters as high is
    # tolerable, but despite and in spite of these efforts, poorly chosen short
    # passwords are not infeasible to acquire through brute force.
    #
    # The fallability is countered by invalidating and recycling the (inter session)
    # key on every login, thus reducing the time frame available to an attacker.
    #
    # <b>The Weakness of the Shell Intra Sessionary Key</b>
    #
    # The shell key hails from a super random (infeasible to crack) source of
    # 48 binary bytes. So what is its achilles heel?
    #
    # The means of protecting the shell key is the weakness. The source of its
    # protection key is a motley crue of data unique not just to the workstation,
    # but the parent shell. This is also passed through key derivation functions
    # to strengthen it.
    #
    # <em><b>Temporary Environment Variables</b></em>
    #
    # The shell key's ciphertext lives as a short term environment variable so
    # <b>when the shell dies the ciphertext dies</b> and any opportunity to resurrect
    # the shell key <b>dies with it</b>.
    #
    # A <b>logout</b> command <b>removes the random iv and ciphertext</b> forged
    # when the shell acted to encrypt the content key. Even mid shell session, a
    # logout renders the shell key worthless.
    #
    # <b>Which (BreadCrumbs) endure?</b>
    #
    # Only <b>4 things endure</b> post the <b>login (recycle)</b> activities.
    # These are the
    #
    # - salts and iteration counts used to generate the inter-session key
    # - index key ciphertext after encryption using the inter-session key
    # - index key ciphertext after encryption using the intra-session key
    # - <b>content ciphertext</b> after the decrypt re-encrypt activities
    #
    #
    # @param domain_name [String]
    #    the string reference that points to the application instance
    #    that is being initialized on this machine.
    #
    # @param domain_secret [String]
    #    the secret text that can potentially be cryptographically weak (low entropy).
    #    This text is severely strengthened and morphed into a key using multiple key
    #    derivation functions like <b>PBKDF2, BCrypt</b> and <b>SCrypt</b>.
    #
    #    The secret text is discarded and the <b>derived inter-session key</b> is used
    #    only to encrypt the <em>randomly generated super strong <b>index key</b></em>,
    #    <b>before being itself discarded</b>.
    #
    #    The key ring only stores the salts. This means the secret text based key can
    #    only be regenerated at the next login, which explains the inter-session label.
    #
    #    <b>Note on Password Key Derivation</b>
    #    For each guess, a brute force attacker would need to perform
    #    <b>one million PBKDF2</b> and <b>65,536 BCrypt</b> algorithm
    #    iterations.
    #
    #    Even so, a password of 6 characters or less can be successfully
    #    attacked. With all earth's computing resources working exclusively
    #    and in concert on attacking one password, it would take over
    #    <b>one million years to access the key</b> derived from a well spread
    #    24 character password. And the key becomes obsolete the next time
    #    you login.
    #
    #    Use the above information to decide on secrets with sufficient
    #    entropy and spread with at least 12 characters.
    #
    # @param content_header [String]
    #    the content header tops the ciphertext storage file with details of how where
    #    and why the file came to be.
    def self.do_login( domain_name, domain_secret, content_header  )

      # --
      # -- Get the breadcrumbs trail.
      # --
      crumbs_db = get_crumbs_db_from_domain_name( domain_name )

      # --
      # -- Get the old inter-sessionary key (created during the previous login)
      # -- Get the old content encryption (power) key (again created during the previous login)
      # -- Get the old random initialization vector (created during the previous login)
      # --
      old_inter_key = KdfApi.regenerate_from_salts( domain_secret, crumbs_db )
      old_power_key = old_inter_key.do_decrypt_key( crumbs_db.get( INTER_KEY_CIPHERTEXT ) )
      old_random_iv = KeyIV.in_binary( crumbs_db.get( INDEX_DB_CRYPT_IV_KEY ) )

      # --
      # -- Read the binary text representing the encrypted content
      # -- that was last written by any use case capable of changing
      # -- the application database content.
      # --
      from_filepath = content_ciphertxt_file_from_domain_name( domain_name )
      old_crypt_txt = binary_from_read( from_filepath )

      # --
      # -- Decrypt the binary ciphertext that was last written by a use case
      # -- capable of changing the application database.
      # --
      plain_content = old_power_key.do_decrypt_text( old_random_iv, old_crypt_txt )

      # --
      # -- Create a new power key and lock the content with it.
      # -- Create a new inter key and lock the power key with it.
      # -- Leave the necessary breadcrumbs for regeneration.
      # -- Return the new power key that re-locked the content.
      # --
      power_key = recycle_keys( domain_name, domain_secret, crumbs_db, content_header, plain_content )

      # --
      # -- Regenerate intra-session key from the session token.
      # -- Encrypt power key for intra (in) session retrieval.
      # --
      intra_key = KeyLocal.regenerate_shell_key( to_token() )
      intra_txt = intra_key.do_encrypt_key( power_key )

      # --
      # -- Set the (ciphertext) breadcrumbs for re-acquiring the
      # -- content encryption (power) key during (inside) this
      # -- shell session.
      # --
      app_id = KeyId.derive_app_instance_identifier( domain_name )
      unique_id = KeyId.derive_universal_id( app_id, to_token() )
      crumbs_db.use( unique_id )
      crumbs_db.set( INTRA_KEY_CIPHERTEXT, intra_txt )
      crumbs_db.set( SESSION_LOGIN_DATETIME, KeyNow.fetch() )

      # --
      # -- Switch the dominant application domain being used to
      # -- the domain that has just logged in.
      # --
      use_application_domain( domain_name )

    end


    # Switch the application instance that the current shell session is using.
    # Trigger this method either during the login use case or when the user
    # issues an intent to use a different application instance.
    #
    # The machine configuration file at path {MACHINE_CONFIG_FILE} is changed
    # in the following way
    #
    # - a {SESSION_APP_DOMAINS} section is added if one does not exist
    # - the shell session ID key is added (or updated if it exists)
    # - with a value corresponding to the app instance ID (on this machine)
    #
    # @param domain_name [String]
    #    the string reference that points to the global application identifier
    #    no matter the machine being used.
    def self.use_application_domain( domain_name )

      KeyError.not_new( domain_name, self )

      aim_id = KeyId.derive_app_instance_machine_id( domain_name )
      sid_id = KeyId.derive_session_id( to_token() )

      keypairs = KeyPair.new( MACHINE_CONFIG_FILE )
      keypairs.use( SESSION_APP_DOMAINS )
      keypairs.set( sid_id, aim_id )

    end


    # <b>Logout of the shell key session</b> by making the high entropy content
    # encryption key <b>irretrievable for all intents and purposes</b> to anyone
    # who does not possess the domain secret.
    #
    # The key logout action is deleting the ciphertext originally produced when
    # the intra-sessionary (shell) key encrypted the content encryption key.
    #
    # <b>Why Isn't the Session Token Deleted?</b>
    #
    # The session token is left to <b>die by natural causes</b> so that we don't
    # interfere with other domain interactions that may be in progress within
    # this shell session.
    #
    # @param domain_name [String]
    #    the string reference that points to the application instance that we
    #    are logging out of from the shell on this machine.
    def self.do_logout( domain_name )

      # --> @todo - user should ONLY type in logout | without domain name
      # --> @todo - user should ONLY type in logout | without domain name
      # --> @todo - user should ONLY type in logout | without domain name
      # --> @todo - user should ONLY type in logout | without domain name
      # --> @todo - user should ONLY type in logout | without domain name


      # --> ######################
      # --> Login / Logout Time
      # --> ######################
      # -->
      # --> During login you create a section heading same as the session ID
      # -->    You then put the intra-key ciphertext there (from locking power key)
      # -->    To check if a login has occurred we ensure this session's ID exists as a header in crumbs DB
      # -->    On logout we remove the session ID and all the subsection crumbs (intra key ciphertext)
      # -->    Logout makes it impossible to access the power key (now only by seret delivery and the inter key ciphertext)
      # -->


      # --
      # -- Get the breadcrumbs trail.
      # --
      crumbs_db = get_crumbs_db_from_domain_name( domain_name )


      # --
      # -- Set the (ciphertext) breadcrumbs for re-acquiring the
      # -- content encryption (power) key during (inside) this
      # -- shell session.
      # --
      unique_id = KeyId.derive_universal_id( domain_name )
      crumbs_db.use( unique_id )
      crumbs_db.set( INTRA_KEY_CIPHERTEXT, intra_txt )
      crumbs_db.set( SESSION_LOGOUT_DATETIME, KeyNow.fetch() )

    end


    # Has the user orchestrating this shell session logged in? Yes or no?
    # If yes then they appear to have supplied the correct secret
    #
    # - in this shell session
    # - on this machine and
    # - for this application instance
    #
    # Use the crumbs found underneath the universal (session) ID within the
    # main breadcrumbs file for this application instance.
    #
    # Note that the system does not rely on this value for its security, it
    # exists only to give a pleasant error message.
    #
    # @return [Boolean]
    #    return true if a marker denoting that this shell session with this
    #    application instance on this machine has logged in. Subverting this
    #    return value only serves to evoke disgraceful degradation.
    def self.is_logged_in?( domain_name )
############## Write this code.
############## Write this code.
############## Write this code.
############## Write this code.
############## Write this code.
############## Write this code.
############## Write this code.
      return false unless File.exists?( frontend_keystore_file() )

      crumbs_db = KeyPair.new( frontend_keystore_file() )
      crumbs_db.use( APP_KEY_DB_BREAD_CRUMBS )
      return false unless crumbs_db.contains?( LOGGED_IN_APP_SESSION_ID )

      recorded_id = crumbs_db.get( LOGGED_IN_APP_SESSION_ID )
      return recorded_id.eql?( @uni_id )

    end


    # Return a date/time string detailing when the master database was first created.
    #
    # @param the_master_db [Hash]
    #    the master database to inspect = REFACTOR convert methods into a class instance
    #
    # @return [String]
    #    return a date/time string representation denoting when the master database
    #    was first created.
    def self.to_db_create_date( the_master_db )
      return the_master_db[ DB_CREATE_DATE ]
    end


    # Return the domain name of the master database.
    #
    # @param the_master_db [Hash]
    #    the master database to inspect = REFACTOR convert methods into a class instance
    #
    # @return [String]
    #    return the domain name of the master database.
    def self.to_db_domain_name( the_master_db )
      return the_master_db[ DB_DOMAIN_NAME ]
    end


    # Return the domain ID of the master database.
    #
    # @param the_master_db [Hash]
    #    the master database to inspect = REFACTOR convert methods into a class instance
    #
    # @return [String]
    #    return the domain ID of the master database.
    def self.to_db_domain_id( the_master_db )
      return the_master_db[ DB_DOMAIN_ID ]
    end


    # Return a dictionary containing a string key and the corresponding master database
    # value whenever the master database key starts with the parameter string.
    #
    # For example if the master database contains a dictionary like this.
    #
    #      envelope@earth => { radius => 24034km, sun_distance_light_minutes => 8 }
    #      textfile@kepler => { filepath => $HOME/keplers_laws.txt, filekey => Nsf8F34dhDT34jLKsLf52 }
    #      envelope@jupiter => { radius => 852837km, sun_distance_light_minutes => 6 }
    #      envelope@pluto => { radius => 2601km, sun_distance_light_minutes => 52 }
    #      textfile@newton => { filepath => $HOME/newtons_laws.txt, filekey => sdDFRTTYu4567fghFG5Jl }
    #
    # with "envelope@" as the start string to match.
    # The returned dictionary would have 3 elements whose keys are the unique portion of the string.
    #
    #      earth => { radius => 24034km, sun_distance_light_minutes => 8 }
    #      jupiter => { radius => 852837km, sun_distance_light_minutes => 6 }
    #      pluto => { radius => 2601km, sun_distance_light_minutes => 52 }
    #
    # If no matches are found an empty dictionary is returned.
    #
    # @param the_master_db [Hash]
    #    the master database to inspect = REFACTOR convert methods into a class instance
    #
    # @param start_string [String]
    #    the start string to match. Every key in the master database that
    #    starts with this string is considered a match. The corresponding value
    #    of each matching key is appended onto the end of an array.
    #
    # @return [Hash]
    #    a dictionary whose keys are the unique (2nd) portion of the string with corresponding
    #    values and in no particular order.
    def self.to_matching_dictionary( the_master_db, start_string )

      matching_dictionary = {}
      the_master_db.each_key do | db_key |
        next unless db_key.start_with?( start_string )
        dictionary_key = db_key.gsub( start_string, "" )
        matching_dictionary.store( dictionary_key, the_master_db[db_key] )
      end
      return matching_dictionary

    end


    # To read the content we first find the appropriate shell key and the
    # appropriate database ciphertext, one decrypts the other to produce the master
    # database decryption key which in turn reveals the JSON representation of the
    # master database.
    #
    # The master database JSON is deserialized as a {Hash} and returned.
    #
    # <b>Steps Taken To Read the Master Database</b>
    #
    # Reading the master database requires a rostra of actions namely
    #
    # - reading the path to the <b>keystore breadcrumbs file</b>
    # - using the session token to derive the (unique to the) shell key
    # - using the shell key and ciphertext to unlock the index key
    # - reading the encrypted and encoded content, decoding and decrypting it
    # - employing index key, ciphertext and random iv to reveal the content
    #
    # @return [String]
    #    decode, decrypt and hen return the plain text content that was written
    #    to a file by the {write_content} method.
    def self.read_master_db()

      # --
      # -- Get the filepath to the breadcrumbs file using the trail in
      # -- the global configuration left by {use_application_domain}.
      # --
      crumbs_db = get_crumbs_db_from_session_token()

      # --
      # -- Get the path to the file holding the ciphertext of the application
      # -- database content locked by the content encryption key.
      # --
      crypt_filepath = content_ciphertxt_file_from_session_token()

      # --
      # -- Regenerate intra-session key from the session token.
      # --
      intra_key = KeyLocal.regenerate_shell_key( to_token() )

      # --
      # -- Decrypt and acquire the content enryption key that was created
      # -- during the login use case and encrypted using the intra sessionary
      # -- key.
      # --
      unique_id = KeyId.derive_universal_id( read_app_id(), to_token() )
      crumbs_db.use( unique_id )
      power_key = intra_key.do_decrypt_key( crumbs_db.get( INTRA_KEY_CIPHERTEXT ) )

      # --
      # -- Set the (ciphertext) breadcrumbs for re-acquiring the
      # -- content encryption (power) key during (inside) this
      # -- shell session.
      # --
      crumbs_db.use( APP_KEY_DB_BREAD_CRUMBS )
      random_iv = KeyIV.in_binary( crumbs_db.get( INDEX_DB_CRYPT_IV_KEY ) )

      # --
      # -- Get the full ciphertext file (warts and all) and then top and
      # -- tail until just the valuable ciphertext is at hand. Decode then
      # -- decrypt the ciphertext and instantiate a key database from the
      # -- resulting JSON string.
      # --
      crypt_txt = binary_from_read( crypt_filepath )
      json_content = power_key.do_decrypt_text( random_iv, crypt_txt )

      return KeyDb.from_json( json_content )

    end


    # This write content behaviour takes the parameter content, encyrpts and
    # encodes it using the index key, which is itself derived from the shell
    # key unlocking the intra session ciphertext. The crypted content is
    # written to a file whose path is derviced by {content_ciphertxt_file_from_domain_name}.
    #
    # <b>Steps Taken To Write the Content</b>
    #
    # Writing the content requires a rostra of actions namely
    #
    # - deriving filepaths to both the breadcrumb and ciphertext files
    # - creating a random iv and adding its base64 form to the breadcrumbs
    # - using the session token to derive the (unique to the) shell key
    # - using the shell key and (intra) ciphertext to acquire the index key
    # - using the index key and random iv to encrypt and encode the content
    # - writing the resulting ciphertext to a file at the designated path
    #
    # @param content_header [String]
    #    the string that will top the ciphertext content when it is written
    #
    # @param app_database [KeyDb]
    #    this key database class will be streamed using its {Hash.to_json}
    #    method and the resulting content will be encrypted and written to
    #    the file at path {content_ciphertxt_file_from_session_token}.
    #
    #    This method's mirror is {read_master_db}.
    def self.write_master_db( content_header, app_database )

      # --
      # -- Get the filepath to the breadcrumbs file using the trail in
      # -- the global configuration left by {use_application_domain}.
      # --
      crumbs_db = get_crumbs_db_from_session_token()

      # --
      # -- Get the path to the file holding the ciphertext of the application
      # -- database content locked by the content encryption key.
      # --
      crypt_filepath = content_ciphertxt_file_from_session_token()

      # --
      # -- Regenerate intra-session key from the session token.
      # --
      intra_key = KeyLocal.regenerate_shell_key( to_token() )

      # --
      # -- Decrypt and acquire the content enryption key that was created
      # -- during the login use case and encrypted using the intra sessionary
      # -- key.
      # --
      unique_id = KeyId.derive_universal_id( read_app_id(), to_token() )
      crumbs_db.use( unique_id )
      power_key = intra_key.do_decrypt_key( crumbs_db.get( INTRA_KEY_CIPHERTEXT ) )

      # --
      # -- Create a new random initialization vector (iv) to use when
      # -- encrypting the incoming database content before writing it
      # -- out to the file at the crypt filepath.
      # --
      iv_base64_chars = KeyIV.new().for_storage()
      crumbs_db.use( APP_KEY_DB_BREAD_CRUMBS )
      crumbs_db.set( INDEX_DB_CRYPT_IV_KEY, iv_base64_chars )
      random_iv = KeyIV.in_binary( iv_base64_chars )

      # --
      # -- Now we use the content encryption (power) key and the random initialization
      # -- vector (iv) to first encrypt the incoming content and then to Base64 encode
      # -- the result. This is then written into the crypt filepath derived earlier.
      # --
      binary_ciphertext = power_key.do_encrypt_text( random_iv, app_database.to_json )
      binary_to_write( crypt_filepath, content_header, binary_ciphertext )

    end



    # If the <b>content dictionary is not nil</b> and contains a key named
    # {CONTENT_EXTERNAL_ID} then we return true as we expect the content
    # ciphertext and its corresponding file to exist.
    #
    # This method throws an exception if they key exists but there is no
    # file at the expected location.
    #
    # @param crumbs_map [Hash]
    #
    #    we test for the existence of the constant {CONTENT_EXTERNAL_ID}
    #    and if it exists we assert that the content filepath should also
    #    be present.
    #
    def self.db_envelope_exists?( crumbs_map )

      return false if crumbs_map.nil?
      return false unless crumbs_map.has_key?( CONTENT_EXTERNAL_ID )

      external_id = crumbs_map[ CONTENT_EXTERNAL_ID ]
      the_filepath = content_filepath( external_id )
      error_string = "External ID #{external_id} found but no file at #{the_filepath}"
      raise RuntimeException, error_string unless File.file?( the_filepath )

      return true

    end


    # This method depends on {use_application_domain} which sets
    # the application ID against the session identity so only call
    # it if we are in a logged in state.
    #
    # NOTE this will NOT be set until the session is logged in so
    # the call fails before that. For this reason do not call this
    # method from outside this class. If the domain name is
    # available use {KeyId.derive_app_instance_identifier} instead.
    def self.read_app_id()

      aim_id = read_aim_id()
      keypairs = KeyPair.new( MACHINE_CONFIG_FILE )
      keypairs.use( aim_id )
      return keypairs.get( APP_INSTANCE_ID_KEY )

    end


    def self.read_aim_id()

      session_identifier = KeyId.derive_session_id( to_token() )

      keypairs = KeyPair.new( MACHINE_CONFIG_FILE )
      keypairs.use( SESSION_APP_DOMAINS )
      return keypairs.get( session_identifier )

    end


    private


    # --------------------------------------------------------
    # In order to separate keys into a new gem we must
    # break knowledge of this variable name and have it
    # instead passed in by clients.
    TOKEN_VARIABLE_NAME = "SAFE_TTY_TOKEN"
    TOKEN_VARIABLE_SIZE = 152
    # --------------------------------------------------------

    CONTENT_IDENTIFIER_LENGTH = 14

    SESSION_APP_DOMAINS = "session.app.domains"
    SESSION_IDENTIFIER_KEY = "session.identifiers"
    KEYSTORE_IDENTIFIER_KEY = "keystore.url.id"
    APP_INSTANCE_ID_KEY = "app.instance.id"
    AIM_IDENTITY_REF_KEY = "aim.identity.ref"
    LOGIN_TIMESTAMP_KEY = "login.timestamp"
    LOGOUT_TIMESTAMP_KEY = "logout.timestamp"
    MACHINE_CONFIGURATION = "machine.configuration"

    APP_INSTANCE_SETUP_TIME = "app.instance.setup.time"

    APP_KEY_DB_NAME_PREFIX = "openkey.breadcrumbs"
    FILE_CIPHERTEXT_PREFIX = "openkey.cipher.file"
    OK_BASE_FOLDER_PREFIX   = "openkey.store"
    OK_BACKEND_CRYPT_PREFIX = "backend.crypt"

    APP_KEY_DB_DIRECTIVES = "key.db.directives"
    APP_KEY_DB_CREATE_TIME_KEY = "initialize.time"
    APP_KEY_DB_BREAD_CRUMBS = "openkey.bread.crumbs"

    LOGGED_IN_APP_SESSION_ID = "logged.in.app.session.id"
    SESSION_LOGIN_DATETIME = "session.login.datetime"
    SESSION_LOGOUT_DATETIME = "session.logout.datetime"

    INTER_KEY_CIPHERTEXT = "inter.key.ciphertext"
    INTRA_KEY_CIPHERTEXT = "intra.key.ciphertext"
    INDEX_DB_CRYPT_IV_KEY = "index.db.cipher.iv"



    def self.get_crumbs_db_from_domain_name( domain_name )

      KeyError.not_new( domain_name, self )
      keystore_file = get_keystore_file_from_domain_name( domain_name )
      crumbs_db = KeyPair.new( keystore_file )
      crumbs_db.use( APP_KEY_DB_BREAD_CRUMBS )
      return crumbs_db

    end


    def self.get_crumbs_db_from_session_token()

      keystore_file = get_keystore_file_from_session_token()
      crumbs_db = KeyPair.new( keystore_file )
      crumbs_db.use( APP_KEY_DB_BREAD_CRUMBS )
      return crumbs_db

    end


    def self.get_store_folder()

      aim_id = read_aim_id()
      app_id = read_app_id()
      return get_app_keystore_folder( aim_id, app_id )

    end


    def self.get_app_keystore_folder( aim_id, app_id )

      keypairs = KeyPair.new( MACHINE_CONFIG_FILE )
      keypairs.use( aim_id )
      keystore_url = keypairs.get( KEYSTORE_IDENTIFIER_KEY )
      basedir_name = "#{OK_BASE_FOLDER_PREFIX}.#{app_id}"
      return File.join( keystore_url, basedir_name )

    end


    def self.get_keystore_file_from_domain_name( domain_name )

      aim_id = KeyId.derive_app_instance_machine_id( domain_name )
      app_id = KeyId.derive_app_instance_identifier( domain_name )

      app_key_db_file = "#{APP_KEY_DB_NAME_PREFIX}.#{app_id}.ini"
      return File.join( get_app_keystore_folder( aim_id, app_id ), app_key_db_file )

    end


    def self.get_keystore_file_from_session_token()

      aim_id = read_aim_id()
      app_id = read_app_id()

      app_key_db_file = "#{APP_KEY_DB_NAME_PREFIX}.#{app_id}.ini"
      return File.join( get_app_keystore_folder( aim_id, app_id ), app_key_db_file )

    end


    def self.content_ciphertxt_file_from_domain_name( domain_name )

      aim_id = KeyId.derive_app_instance_machine_id( domain_name )
      app_id = KeyId.derive_app_instance_identifier( domain_name )

      appdb_cipher_file = "#{FILE_CIPHERTEXT_PREFIX}.#{app_id}.txt"
      return File.join( get_app_keystore_folder( aim_id, app_id ), appdb_cipher_file )

    end


    def self.content_ciphertxt_file_from_session_token()

      aim_id = read_aim_id()
      app_id = read_app_id()

      appdb_cipher_file = "#{FILE_CIPHERTEXT_PREFIX}.#{app_id}.txt"
      return File.join( get_app_keystore_folder( aim_id, app_id ), appdb_cipher_file )

    end


    def self.to_token()

      raw_env_var_value = ENV[TOKEN_VARIABLE_NAME]
      raise_token_error( TOKEN_VARIABLE_NAME, "not present") unless raw_env_var_value

      env_var_value = raw_env_var_value.strip
      raise_token_error( TOKEN_VARIABLE_NAME, "consists only of whitespace") if raw_env_var_value.empty?

      size_msg = "length should contain exactly #{TOKEN_VARIABLE_SIZE} characters"
      raise_token_error( TOKEN_VARIABLE_NAME, size_msg ) unless env_var_value.length == TOKEN_VARIABLE_SIZE

      return env_var_value

    end


  end


end
