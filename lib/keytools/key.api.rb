#!/usr/bin/ruby

module SafeDb

  # Use RubyMine to understand the correlations and dependencies on
  # this now monolithic class that must be broken up before meaningful
  # effective and efficient progress can be made.
  #
  # ---
  #
  # == REFACTOR KEY API TO DRAW OUT POSSIBLY THESE FIVE CONCEPTS.
  # 
  # - [1] the safe tty token
  # - [2] the machine configurations in ~/.config/openkey/openkey.app.config.ini
  # - [3] the login / logout session crumbs database
  # - [4] the master content database holding local config, chapters and verses
  # - [5] the safe databases that unmarshal into either JSON or file content
  # 
  # ---
  # 
  # Use the key applications programming interface to transition the
  # state of three (3) core keys in accordance with the needs of the
  # executing use case.
  #
  # == KeyApi | The 3 Keys
  #
  # The three keys service the needs of a <b>command line application</b>
  # that executes within a <b>shell environment in a unix envirronment</b>
  # or a <b>command prompt in windows</b>.
  #
  # So what are the 3 keys and what is their purpose.
  #
  # - shell key | exists to lock the index key created at login
  # - human key | exists to lock the index key created at login
  # - index key | exists to lock the application's index file
  #
  # So why do two keys (the shell key and human key) exist to lock the
  # same index key?
  #
  # == KeyApi | Why Lock the Index Key Twice?
  #
  # On this login, the <b>previous login's human key is regenerated</b> from
  # the <b>human password and the saved salts</b>. This <em>old human key</em>
  # decrypts and reveals the <b><em>old index key</em></b> which in turn
  # decrypts and reveals the index string.
  #
  # Both the old human key and the old index key are discarded.
  #
  # Then 48 bytes of randomness are sourced to generate the new index key. This
  # key encrypts the now decrypted index string and is thrown away. The password
  # sources a new human key (the salts are saved), and this new key locks the
  # index key's source bytes.
  #
  # The shell key again locks the index key's source bytes. <b><em>Why twice?</em></b>
  #
  # - during subsequent shell command calls the human key is unavailable however
  #   the index key can be accessed via the shell key.
  #
  # - when the shell dies (or logout is issued) the shell key dies. Now the index
  #   key can only be accessed by a login when the password is made available.
  #
  # That is why the index key is locked twice. The shell key opens it mid-session
  # and the regenerated human key opens it during the login of the next session.
  #
  # == The LifeCycle of each Key
  #
  # It seems odd that the human key is born during this login then dies
  # at the very next one (as stated below). This is because the human key
  # isn't the password, <b>the human key is sourced from the password</b>.
  #
  # So when are the 3 keys <b>born</b> and when do they <b>cease being</b>.
  #
  # - shell key | is born when the shell is created and dies when the shell dies
  # - human key | is born when the user logs in this time and dies at the next login
  # - index key | the life of the index key exactly mirrors that of the human key
  #
  # == The 7 Key API Calls
  #
  #   | - | -------- | ------------ | ------------------------------- |
  #   | # | Rationale                       | Use Case | Goals   |  Tasks        |
  #   | - | ------------------------------- | ------------ | ------------------------------- |
  #   | 1 | Create and Obfuscate Shell Key  | key      | x |  y  |
  #   | 2 | New App Instance on Workstation | init     | x |  y  |
  #   | 3 | Login to App Instance in Shell  | login    | x |  y  |
  #
  class KeyApi


    # Transform the domain secret into a key, use that key to lock the
    # power key, delete the secret and keys and leave behind a trail of
    # <b>breadcrumbs sprinkled</b> to allow the <b>inter-sessionary key</b>
    # to be <b>regenerated</b> at the <b>next login</b>.
    #
    # <b>Lest we forget</b> - buried within this ensemble of activities, is
    # <b>generating the high entropy power key</b>, using it to lock the
    # application database before discarding it.
    #
    # The use case steps once the human secret is acquired is to
    #
    # - pass it through key derivation functions
    # - generate a high entropy power key and lock some initial content with it
    # - use the key sourced from the human secret to lock the power key
    # - throw away the secret, power key and human sourced key
    # - save crumbs (ciphertext, salts, ivs) for content retrieval given secret
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
    # @param content_header [String]
    #    the content header tops the ciphertext storage file with details of how where
    #    and why the file came to be.
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


    # Recycle the inter-sessionary key (based on the secret) and create a new
    # content encryption (power) key and lock the parameter content with it
    # before returning the new content encryption key.
    #
    # The {content_ciphertxt_file_from_domain_name} method is used to produce the path at which
    # the ciphertext (resulting from locking the parameter content), is stored.
    #
    # @param domain_name [String]
    #
    #    the (application instance) domain name chosen by the user or the
    #    machine that is interacting with the SafeDb software.
    #
    # @param domain_secret [String]
    #
    #    the domain secret that is put through key derivation functions in order
    #    to attain the strongest possible inter-sessionary key which is used only
    #    to encrypt and decrypt the high-entropy content encryption key.
    #
    # @param crumbs_db [KeyPair]
    #
    #    The crumbs database is expected to be initialized with a section
    #    ready to receive breadcrumb data. The crumbs data injected are
    #
    #    - a random iv for future AES decryption of the parameter content
    #    - cryptographic salts for future rederivation of the inter-sessionary key
    #    - the resultant ciphertext from the inter key locking the content key
    #
    # @param the_content [String]
    #
    #    the app database content whose ciphertext is to be recycled using the
    #    recycled (newly derived) high entropy random content encryption key.
    def self.recycle_keys( domain_name, domain_secret, crumbs_db, content_header, the_content )

      KeyError.not_new( domain_name, self )
      KeyError.not_new( domain_secret, self )
      KeyError.not_new( the_content, self )

      # --
      # -- Create a random initialization vector (iv)
      # -- used for AES encryption of virgin content
      # --
      iv_base64_chars = KeyIV.new().for_storage()
      crumbs_db.set( INDEX_DB_CRYPT_IV_KEY, iv_base64_chars )
      random_iv = KeyIV.in_binary( iv_base64_chars )

      # --
      # -- Create a new high entropy power key
      # -- for encrypting the virgin content.
      # --
      power_key = Key.from_random

      # --
      # -- Encrypt the virgin content using the
      # -- power key and the random iv and write
      # -- the Base64 encoded ciphertext into a
      # -- neighbouring file.
      # --
      to_filepath = content_ciphertxt_file_from_domain_name( domain_name )
      binary_ciphertext = power_key.do_encrypt_text( random_iv, the_content )
      binary_to_write( to_filepath, content_header, binary_ciphertext )

      # --
      # -- Derive new inter-sessionary key.
      # -- Use it to encrypt the power key.
      # -- Set the reretrieval breadcrumbs.
      # --
      inter_key = KdfApi.generate_from_password( domain_secret, crumbs_db )
      inter_txt = inter_key.do_encrypt_key( power_key )
      crumbs_db.set( INTER_KEY_CIPHERTEXT, inter_txt )

      # --
      # -- Return the just createdC high entropy
      # -- content encryption (power) key.
      # --
      return power_key

    end



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


    # Generate a new set of envelope breadcrumbs, derive the new envelope
    # filepath, then <b>encrypt</b> the raw envelope content, and write the
    # resulting ciphertext out into the new file.
    #
    # The important parameters in play are the
    #
    # - session token used to find the storage folder
    # - random envelope external ID used to name the ciphertext file
    # - generated random key for encrypting and decrypting the content
    # - generated random initialization vector (IV) for crypting
    # - name of the file in which the locked content is placed
    # - header and footer content that tops and tails the ciphertext
    #
    # @param crumbs_map [Hash]
    #
    #    nothing is read from this crumbs map but 3 things are written to
    #    it with these corresponding key names
    #
    #    - random content external ID {CONTENT_EXTERNAL_ID}
    #    - high entropy crypt key     {CONTENT_ENCRYPT_KEY}
    #    - and initialization vector  {CONTENT_RANDOM_IV}
    #
    # @param content_body [String]
    #
    #    this is the envelope's latest and greatest content that will
    #    be encrypted, encoded, topped, tailed and then pushed out to
    #    the domain's storage folder.
    #
    # @param content_header [String]
    #
    #    the string that will top the ciphertext content when it is written
    #
    def self.content_lock( crumbs_map, content_body, content_header )

      # --
      # -- Create the external content ID and place
      # -- it within the crumbs map.
      # --
      content_exid = get_random_reference()
      crumbs_map[ CONTENT_EXTERNAL_ID ] = content_exid

      # --
      # -- Create a random initialization vector (iv)
      # -- for AES encryption and store it within the
      # -- breadcrumbs map.
      # --
      iv_base64 = KeyIV.new().for_storage()
      random_iv = KeyIV.in_binary( iv_base64 )
      crumbs_map[ CONTENT_RANDOM_IV ] = iv_base64

      # --
      # -- Create a new high entropy random key for
      # -- locking the content with AES. Place the key
      # -- within the breadcrumbs map.
      # --
      crypt_key = Key.from_random()
      crumbs_map[ CONTENT_ENCRYPT_KEY ] = crypt_key.to_char64()

      # --
      # -- Now use AES to lock the content body and write
      # -- the encoded ciphertext out to a file that is
      # -- topped with the parameter content header.
      # --
      binary_ctext = crypt_key.do_encrypt_text( random_iv, content_body )
      content_path = content_filepath( content_exid )
      binary_to_write( content_path, content_header, binary_ctext )

    end


    # Use the content's external id expected in the breadcrumbs together with
    # the session token to derive the content's filepath and then unlock and
    # the content as a {KeyDb} structure.
    #
    # Unlocking the content means reading it, decoding and then decrypting it using
    # the initialization vector (iv) and decryption key whose values are expected
    # within the breadcrumbs map.
    #
    # @param crumbs_map [Hash]
    #
    #    the three (3) data points expected within the breadcrumbs map are the
    #
    #    - content's external ID {CONTENT_EXTERNAL_ID}
    #    - AES encryption key    {CONTENT_ENCRYPT_KEY}
    #    - initialization vector {CONTENT_RANDOM_IV}
    #
    def self.content_unlock( crumbs_map )

      # --
      # -- Get the external ID of the content then use
      # -- that plus the session context to derive the
      # -- content's ciphertext filepath.
      # --
      content_path = content_filepath( crumbs_map[ CONTENT_EXTERNAL_ID ] )

      # --
      # -- Read the binary ciphertext of the content
      # -- from the file. Then decrypt it using the
      # -- AES crypt key and intialization vector.
      # --
      crypt_txt = binary_from_read( content_path )
      random_iv = KeyIV.in_binary( crumbs_map[ CONTENT_RANDOM_IV ] )
      crypt_key = Key.from_char64( crumbs_map[ CONTENT_ENCRYPT_KEY ] )
      text_data = crypt_key.do_decrypt_text( random_iv, crypt_txt )

      return text_data

    end


    # This method returns the <b>content filepath</b> which (at its core)
    # is an amalgam of the application's (domain) identifier and the content's
    # external identifier (XID).
    #
    # The filename is prefixed by {CONTENT_FILE_PREFIX}.
    #
    # @param external_id [String]
    #
    #    nothing is read from this crumbs map but 3 things are written to
    #    it with these corresponding key names
    #
    #    - random content external ID {CONTENT_EXTERNAL_ID}
    #    - high entropy crypt key     {CONTENT_ENCRYPT_KEY}
    #    - and initialization vector  {CONTENT_RANDOM_IV}
    def self.content_filepath( external_id )

      app_identity = read_app_id()
      store_folder = get_store_folder()
      env_filename = "#{CONTENT_FILE_PREFIX}.#{external_id}.#{app_identity}.txt"
      env_filepath = File.join( store_folder, env_filename )
      return env_filepath

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


    # Construct the header for the ciphertext content files written out
    # onto the filesystem.
    #
    # @param gem_version [String] the current version number of the calling gem
    # @param gem_name [String] the current name of the calling gem
    # @param gem_site [String] the current website of the calling gem
    #
    # @param the_domain_name [String]
    #
    #    This method uses one of the two (2) ways to gain the application id.
    #
    #    If not logged in callers will have the domain name and should pass it
    #    in so that this method can use {KeyId.derive_app_instance_identifier}
    #    to gain the application id.
    #
    #    If logged in then method {KeyApi.use_application_domain} will have
    #    executed and the application ID will be written inside the
    #    <b>machine configuration file</b> under the application instance on
    #    machine id and referenced in turn from the {SESSION_APP_DOMAINS} map.
    #
    #    In the above case post a NIL domain name and this method will now
    #    turn to {KeyApi.read_app_id} for the application id.
    def self.format_header( gem_version, gem_name, gem_site, the_domain_name = nil )

      application_id = KeyId.derive_app_instance_identifier(the_domain_name) unless the_domain_name.nil?
      application_id = read_app_id() if the_domain_name.nil?

      line1 = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
      line2 = "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
      line3 = "#{gem_name} ciphertext block\n"
      line4 = "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
      line5 = "SafeDb Book := #{application_id}\n" # application domain reference
      line6 = "Access Time := #{KeyNow.grab()}\n"  # timestamp of the last write
      line7 = "App Version := #{gem_version}\n"    # this application semantic version
      line8 = "Website Url := #{gem_site}\n"       # app website or github url

      return line1 + line2 + line3 + line4 + line5 + line6 + line7 + line8

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


###    MACHINE_CONFIG_FILE = File.join( Dir.home, ".config/openkey/openkey.app.config.ini" )


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

    BLOCK_64_START_STRING = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789ab\n"
    BLOCK_64_END_STRING   = "ba9876543210fedcba9876543210fedcba9876543210fedcba9876543210\n"
    BLOCK_64_DELIMITER    = "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

    XID_SOURCE_APPROX_LEN = 11

    CONTENT_FILE_PREFIX = "tree.db"
    CONTENT_EXTERNAL_ID = "content.xid"
    CONTENT_ENCRYPT_KEY = "content.key"
    CONTENT_RANDOM_IV   = "content.iv"

    DB_CREATE_DATE = "db.create.date"
    DB_DOMAIN_NAME = "db.domain.name"
    DB_DOMAIN_ID = "db.domain.id"


    def self.binary_to_write( to_filepath, content_header, binary_ciphertext )

      base64_ciphertext = Base64.encode64( binary_ciphertext )

      content_to_write =
        content_header +
        BLOCK_64_DELIMITER +
        BLOCK_64_START_STRING +
        base64_ciphertext +
        BLOCK_64_END_STRING +
        BLOCK_64_DELIMITER

      File.write( to_filepath, content_to_write )

    end


    def self.binary_from_read( from_filepath )

      file_text = File.read( from_filepath )
      core_data = file_text.in_between( BLOCK_64_START_STRING, BLOCK_64_END_STRING ).strip
      return Base64.decode64( core_data )

    end


    def self.get_random_reference

      # Do not forget that you can pass this through
      # the derive identifier method if uniformity is
      # what you seek.
      #
      #    [  KeyId.derive_identifier( reference )  ]
      #
      random_ref = SecureRandom.urlsafe_base64( XID_SOURCE_APPROX_LEN ).delete("-_").downcase
      return random_ref[ 0 .. ( XID_SOURCE_APPROX_LEN - 1 ) ]

    end


    def self.get_virgin_content( domain_name )

      KeyError.not_new( domain_name, self )
      app_id = KeyId.derive_app_instance_identifier( domain_name )

      initial_db = KeyDb.new()
      initial_db.store( DB_CREATE_DATE, KeyNow.fetch() )
      initial_db.store( DB_DOMAIN_NAME, domain_name )
      initial_db.store( DB_DOMAIN_ID, app_id )
      return initial_db.to_json

    end


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


    def self.raise_token_error env_var_name, message

      puts ""
      puts "#{TOKEN_VARIABLE_NAME} environment variable #{message}."
      puts "To instantiate it you can use the below command."
      puts ""
      puts "$ export #{TOKEN_VARIABLE_NAME}=`safe token`"
      puts ""
      puts "ps => those are backticks around `safe token` (not apostrophes)."
      puts ""

      raise RuntimeError, "#{TOKEN_VARIABLE_NAME} environment variable #{message}."

    end


  end


end
