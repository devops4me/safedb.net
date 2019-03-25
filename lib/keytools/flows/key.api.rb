#!/usr/bin/ruby

module SafeDb

  class KeyApi

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
    # The {KeyMap} master database JSON is streamed into one of the crypt files denoted by
    # a content identifier - this file is decrypted and the data structure deserialized
    # into a {Hash} and returned.
    #
    # <b>Steps Taken To Read the Master Database</b>
    #
    # Reading up and returning the master database requires a rostra of actions namely
    #
    # - finding the session data and reading the ID of the book in play
    # - using the content id, session id and book id to locate the crypt file
    # - using the session shell key and salt to unlock the content encryption key
    # - using the content crypt key and random iv to unlock the file's ciphertext
    #
    # @return [String]
    #    decode, decrypt and hen return the plain text content that was written
    #    to a file by the {write_content} method.
    def self.read_master_db()

      session_id = Identifier.derive_session_id( ShellSession.to_token() )
      session_indices_file = FilePath.session_indices_filepath( session_id )
      session_keys = KeyMap.new( session_indices_file )
      book_id = session_keys.read( Indices::SESSION_DATA, Indices::CURRENT_SESSION_BOOK_ID )
      session_keys.use( book_id )
      content_id = session_keys.get( Indices::CONTENT_IDENTIFIER )
      random_iv = KeyIV.in_binary( session_keys.get( Indices::CONTENT_RANDOM_IV ) )
      content_crypt_path = FilePath.session_crypts_filepath( book_id, session_id, content_id )
      intra_key_ciphertext = session_keys.get( Indices::INTRA_SESSION_KEY_CRYPT )

      intra_key = KeyDerivation.regenerate_shell_key( ShellSession.to_token() )
      crypt_key = intra_key.do_decrypt_key( intra_key_ciphertext )
      crypt_txt = Lock.binary_from_read( content_crypt_path )
      json_content = crypt_key.do_decrypt_text( random_iv, crypt_txt )

      return KeyStore.from_json( json_content )

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
    # @param app_database [KeyStore]
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
      intra_key = KeyDerivation.regenerate_shell_key( ShellSession.to_token() )

      # --
      # -- Decrypt and acquire the content enryption key that was created
      # -- during the login use case and encrypted using the intra sessionary
      # -- key.
      # --
      unique_id = Identifier.derive_universal_id( read_app_id(), ShellSession.to_token() )
      crumbs_db.use( unique_id )
      power_key = intra_key.do_decrypt_key( crumbs_db.get( Indices::INTRA_SESSION_KEY_CRYPT ) )

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
    # {Indices::CONTENT_IDENTIFIER} then we return true as we expect the content
    # ciphertext and its corresponding file to exist.
    #
    # This method throws an exception if they key exists but there is no
    # file at the expected location.
    #
    # @param crumbs_map [Hash]
    #
    #    we test for the existence of the constant {Indices::CONTENT_IDENTIFIER}
    #    and if it exists we assert that the content filepath should also
    #    be present.
    #
    def self.db_envelope_exists?( crumbs_map )

      return false if crumbs_map.nil?
      return false unless crumbs_map.has_key?( Indices::CONTENT_IDENTIFIER )

      external_id = crumbs_map[ Indices::CONTENT_IDENTIFIER ]
      the_filepath = content_filepath( external_id )
      error_string = "External ID #{external_id} found but no file at #{the_filepath}"
      raise RuntimeException, error_string unless File.file?( the_filepath )

      return true

    end


    private


    APP_KEY_DB_BREAD_CRUMBS = "openkey.bread.crumbs"
    LOGGED_IN_APP_SESSION_ID = "logged.in.app.session.id"
    SESSION_LOGOUT_DATETIME = "session.logout.datetime"
    INDEX_DB_CRYPT_IV_KEY = "index.db.cipher.iv"

  end


end
