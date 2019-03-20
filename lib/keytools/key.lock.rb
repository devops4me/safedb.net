#!/usr/bin/ruby

module SafeDb

  # This class both locks content, writing the ciphertext to a file, and
  # unlocks content after reading ciphertext from a file.
  #
  # It supports the encryption of large bodies of text or binary because
  # it uses the efficient and effective AES asymmetric algorithm.
  #
  class KeyLock

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



    private



    BLOCK_64_START_STRING = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789ab\n"
    BLOCK_64_END_STRING   = "ba9876543210fedcba9876543210fedcba9876543210fedcba9876543210\n"
    BLOCK_64_DELIMITER    = "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

    XID_SOURCE_APPROX_LEN = 11

    CONTENT_FILE_PREFIX = "tree.db"
    CONTENT_EXTERNAL_ID = "content.xid"
    CONTENT_ENCRYPT_KEY = "content.key"
    CONTENT_RANDOM_IV   = "content.iv"



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
