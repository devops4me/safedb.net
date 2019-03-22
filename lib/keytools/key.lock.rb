#!/usr/bin/ruby

module SafeDb

  # This class both locks content, writing the ciphertext to a file, and
  # unlocks content after reading ciphertext from a file.
  #
  # It supports the encryption of large bodies of text or binary because
  # it uses the efficient and effective AES asymmetric algorithm.
  #
  class KeyLock

    # Lock the content body provided - place the resulting ciphertext
    # inside a file named by a random identifier, then write this identifier
    # along wih the initialization and encryption key into the provided
    # key-value map (hash).
    #
    # The content ciphertext derived from encrypting the body is stored
    # in a file underneath the provided content header.
    #
    # This method returns the highly random key instantiated for the purposes
    # of encrypting the content.
    #
    # @param book_id [String]
    #
    #    this book identifier is used to locate the sub-directory holding
    #    the chapter crypt casket (ccc) files.
    #
    # @param crypt_key [Key]
    #
    #    the key used to (symmetrically) encrypt the content provided
    #
    # @param key_store [Hash]
    #
    #    pass either the DataMap which is a JSON backed store or a KeyMap
    #    that streams to and from INI formatted data. The KeyMap is preferred
    #    for human readable data which is precisely 2 dimensional. The streamed
    #    DataMap is JSON which at scale isn't human readable but the data
    #    structure is N dimensional and it supports nested structures such
    #    as lists, maps, numbers and booleans.
    #
    #    This content locker will write two key-values pairs into the data
    #    structure - namely
    #
    #    - random content identifier {CONTENT_EXTERNAL_ID}
    #    - and initialization vector {CONTENT_RANDOM_IV}
    #
    # @param content_body [String]
    #
    #    this content is encrypted by this method and the ciphertext
    #    result is stored in a file.
    #
    # @param content_header [String]
    #
    #    the string that will top the content's ciphertext when it is written
    #
    def self.content_lock( book_id, crypt_key, key_store, content_body, content_header )

      # --
      # -- Create the external content ID and place
      # -- it within the crumbs map.
      # --

      content_id = KeyRandom.get_random_identifier( CONTENT_ID_LENGTH )
      key_store.set( CONTENT_EXTERNAL_ID, content_id )

      # --
      # -- Create a random initialization vector (iv)
      # -- for AES encryption and store it within the
      # -- breadcrumbs map.
      # --
      iv_base64 = KeyIV.new().for_storage()
      random_iv = KeyIV.in_binary( iv_base64 )
      key_store.set( CONTENT_RANDOM_IV, iv_base64 )

#########      # --
#########      # -- Create a new high entropy random key for
#########      # -- locking the content with AES. Place the key
#########      # -- within the breadcrumbs map.
#########      # --
#########      crypt_key = Key.from_random()
#########      key_store[ CONTENT_ENCRYPT_KEY ] = crypt_key.to_char64()

      # --
      # -- Now use AES to lock the content body and write
      # -- the encoded ciphertext out to a file that is
      # -- topped with the parameter content header.
      # --
      binary_ctext = crypt_key.do_encrypt_text( random_iv, content_body )
      content_file = crypt_filepath( book_id, content_id )
      binary_to_write( content_file, content_header, binary_ctext )

    end


    # Use the content's external id expected in the breadcrumbs together with
    # the session token to derive the content's filepath and then unlock and
    # the content as a {KeyDb} structure.
    #
    # Unlocking the content means reading it, decoding and then decrypting it using
    # the initialization vector (iv) and decryption key whose values are expected
    # within the breadcrumbs map.
    #
    # @param key_store [Hash]
    #
    #    the three (3) data points expected within the breadcrumbs map are the
    #
    #    - content's external ID {CONTENT_EXTERNAL_ID}
    #    - AES encryption key    {CONTENT_ENCRYPT_KEY}
    #    - initialization vector {CONTENT_RANDOM_IV}
    #
    def self.content_unlock( key_store )

      # --
      # -- Get the external ID of the content then use
      # -- that plus the session context to derive the
      # -- content's ciphertext filepath.
      # --
      content_path = content_filepath( key_store[ CONTENT_EXTERNAL_ID ] )

      # --
      # -- Read the binary ciphertext of the content
      # -- from the file. Then decrypt it using the
      # -- AES crypt key and intialization vector.
      # --
      crypt_txt = binary_from_read( content_path )
      random_iv = KeyIV.in_binary( key_store[ CONTENT_RANDOM_IV ] )
      crypt_key = Key.from_char64( key_store[ CONTENT_ENCRYPT_KEY ] )
      text_data = crypt_key.do_decrypt_text( random_iv, crypt_txt )

      return text_data

    end



    private



    def self.crypt_filepath( book_id, content_id )

      ## Change me when we have to use SESSION / BOOK directories for stashing content
      ## Change me when we have to use SESSION / BOOK directories for stashing content
      ## Change me when we have to use SESSION / BOOK directories for stashing content
      ## Change me when we have to use SESSION / BOOK directories for stashing content
      ## Change me when we have to use SESSION / BOOK directories for stashing content
      ## Change me when we have to use SESSION / BOOK directories for stashing content

      crypt_filedir = File.join( Dir.home, ".safedb.net/safedb-master-crypts/safedb.book.#{book_id}" )
      FileUtils.mkdir_p( crypt_filedir )
      return File.join( crypt_filedir, "safedb.chapter.#{content_id}.txt" )

    end


    BLOCK_64_START_STRING = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789ab\n"
    BLOCK_64_END_STRING   = "ba9876543210fedcba9876543210fedcba9876543210fedcba9876543210\n"
    BLOCK_64_DELIMITER    = "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

##############################################    XID_SOURCE_APPROX_LEN = 11

    CONTENT_ID_LENGTH   = 14
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
