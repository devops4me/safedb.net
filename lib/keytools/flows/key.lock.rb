#!/usr/bin/ruby

module SafeDb

  # This class both locks content, writing the ciphertext to a file, and
  # unlocks content after reading ciphertext from a file.
  #
  # It supports the encryption of large bodies of text or binary because
  # it uses the efficient and effective AES asymmetric algorithm.
  #
  class Lock

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
    #    - random content identifier {Indices::CONTENT_IDENTIFIER}
    #    - and initialization vector {Indices::CONTENT_RANDOM_IV}
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

      content_id = Identifier.get_random_identifier( Indices::CONTENT_ID_LENGTH )
      key_store.set( Indices::CONTENT_IDENTIFIER, content_id )

      # --
      # -- Create a random initialization vector (iv)
      # -- for AES encryption and store it within the
      # -- breadcrumbs map.
      # --
      iv_base64 = KeyIV.new().for_storage()
      random_iv = KeyIV.in_binary( iv_base64 )
      key_store.set( Indices::CONTENT_RANDOM_IV, iv_base64 )

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
      content_file = master_crypts_filepath( book_id, content_id )
      binary_to_write( content_file, content_header, binary_ctext )

    end


    # Use the content's external id to find the ciphertext file that is to be unlocked.
    # Then use the unlock key from the parameter along with the random IV that is inside
    # the {KeyMap} or {KeyStore} to decrypt and return the ciphertext.
    #
    # @param unlock_key [Key]
    #
    #    the symmetric key that was used to encrypt the ciphertext
    #
    # @param key_store [KeyMap]
    #
    #    pass through either the {KeyMap} or {KeyStore} that contains both the content's
    #    external ID {Indices::CONTENT_IDENTIFIER} and the initialization vector {Indices::CONTENT_RANDOM_IV}.
    #
    # @return [String]
    #
    #    the resulting decrypted text that was encrypted with the parameter key
    #
    def self.content_unlock( unlock_key, key_store )

####### ---->
####### ---->      crypt_key = Key.from_char64( key_store[ CONTENT_ENCRYPT_KEY ] )
####### ---->
####### ---->  Use the above line to find the key from the book contents index page
####### ---->  that unlocks one of the chapters.
####### ---->
      the_book_id = key_store.section()

      content_path = master_crypts_filepath( the_book_id, key_store.get( Indices::CONTENT_IDENTIFIER ) )
      crypt_txt = binary_from_read( content_path )
      random_iv = KeyIV.in_binary( key_store.get( Indices::CONTENT_RANDOM_IV ) )
      text_data = unlock_key.do_decrypt_text( random_iv, crypt_txt )

      return text_data

    end


## make 2 methods below private once first part of key.api do_login() method is refactored to call unlock
## make 2 methods below private once first part of key.api do_login() method is refactored to call unlock
## make 2 methods below private once first part of key.api do_login() method is refactored to call unlock
## make 2 methods below private once first part of key.api do_login() method is refactored to call unlock
## make 2 methods below private once first part of key.api do_login() method is refactored to call unlock
## make 2 methods below private once first part of key.api do_login() method is refactored to call unlock
## make 2 methods below private once first part of key.api do_login() method is refactored to call unlock
## make 2 methods below private once first part of key.api do_login() method is refactored to call unlock
## make 2 methods below private once first part of key.api do_login() method is refactored to call unlock
## make 2 methods below private once first part of key.api do_login() method is refactored to call unlock

    def self.binary_to_write( to_filepath, content_header, binary_ciphertext )

      base64_ciphertext = Base64.encode64( binary_ciphertext )

      content_to_write =
        content_header +
        Indices::CONTENT_BLOCK_DELIMITER +
        Indices::CONTENT_BLOCK_START_STRING +
        base64_ciphertext +
        Indices::CONTENT_BLOCK_END_STRING +
        Indices::CONTENT_BLOCK_DELIMITER

      File.write( to_filepath, content_to_write )

    end


    def self.binary_from_read( from_filepath )

      file_text = File.read( from_filepath )
      core_data = file_text.in_between( Indices::CONTENT_BLOCK_START_STRING, Indices::CONTENT_BLOCK_END_STRING ).strip
      return Base64.decode64( core_data )

    end



    # When we login to a book which may or may not be the first book in the session
    # that we have logged into, we are effectively cloning all its master crypts and
    # some of its keys (indices).
    #
    # To clone a book into a session we
    #
    # - create a {session_crypts_folder} and copy all master crypts into it
    # - we {create_session_indices} under general and book_id sections
    # - we copy the commit reference and content identifier from the master
    # - lock the content crypt key with the session key and save the ciphertext
    #
    # == commit references
    #
    # We can only commit (save) a session's crypts when the master and session commit
    # references match. The commit process places a new commit reference into both
    # the master and session indices. Like git's push/pull, this prevents a sync when
    # the master has moved forward by one or more commits.
    #
    # @param book_id [String] the book identifier this session is about
    # @param session_id [String] the identifier pertaining to this session
    # @param master_book_keys [KeyMap] keys from the book's master line
    # @param crypt_key [Key] symmetric session content encryption key
    #
    def self.clone_book_into_session( book_id, session_id, master_book_keys, crypt_key )

      FileUtils.mkdir_p( session_crypts_folder( book_id, session_id ) )
      FileUtils.copy_entry( master_crypts_folder( book_id ), session_crypts_folder( book_id, session_id ) )
      session_keys = create_session_indices( book_id, session_id )

      session_keys.set( Indices::CONTENT_IDENTIFIER, master_book_keys.get( Indices::CONTENT_IDENTIFIER ) )
      session_keys.set( Indices::CONTENT_RANDOM_IV,  master_book_keys.get( Indices::CONTENT_RANDOM_IV  ) )
      session_keys.set( Indices::SESSION_COMMIT_ID,  master_book_keys.get( Indices::MASTER_COMMIT_ID   ) )

      session_key = KeyDerivation.regenerate_shell_key( ShellSession.to_token() )
      key_ciphertext = session_key.do_encrypt_key( crypt_key )
      session_keys.set( Indices::INTRA_SESSION_KEY_CRYPT, key_ciphertext )

    end


    # Create and return the session indices {KeyMap} pertaining to both the current
    # book and session whose ids are given in the first and second parameters.
    #
    # @param book_id [String] the book identifier this session is about
    # @param session_id [String] the identifier pertaining to this session
    # @return [KeyMap] return the keys pertaining to this session and book
    def self.create_session_indices( book_id, session_id )

      session_exists = File.exists? session_indices_filepath( session_id )
      session_keys = KeyMap.new( session_indices_filepath( session_id ) )
      session_keys.use( Indices::SESSION_DATA )
      session_keys.set( Indices::SESSION_FIRST_LOG_IN_POINT, KeyNow.readable() ) unless session_exists
      session_keys.set( Indices::SESSION_LAST_ACCESSED_TIME, KeyNow.readable() )
      session_keys.set( Indices::CURRENT_SESSION_BOOK_ID, book_id )

      logged_in = session_keys.has_section?( book_id )
      session_keys.use( book_id )
      session_keys.set( Indices::BOOK_SESSION_LOGIN_TIME, KeyNow.readable() ) unless logged_in
      session_keys.set( Indices::BOOK_LAST_ACCESSED_TIME, KeyNow.readable() )

      return session_keys

    end


    def self.create_master_book_crypts_folder( book_id )
      FileUtils.mkdir_p( master_crypts_folder( book_id ) )
    end


    private


    def self.master_crypts_filepath( book_id, content_id )
      return File.join( master_crypts_folder( book_id ), "safedb.chapter.#{content_id}.txt" )

    end


    def self.master_crypts_folder( book_id )
      return File.join( MASTER_CRYPTS_FOLDER, "safedb.book.#{book_id}" )
    end


    def self.session_crypts_filepath( book_id, session_id, content_id )
      return File.join( session_crypts_folder( book_id, session_id ), "safedb.chapter.#{content_id}.txt" )
    end


    def self.session_crypts_folder( book_id, session_id )
      return File.join( SESSION_CRYPTS_FOLDER, "safedb-session-#{book_id}-#{session_id}" )
    end


    def self.session_indices_filepath( session_id )
      return File.join( SESSION_INDICES_FOLDER, "safedb-indices-#{session_id}.ini" )
    end


    def self.contains_all_master_book_indices( key_map )
      return false unless key_map.contains?( Indices::CONTENT_RANDOM_IV )
      return false unless key_map.contains?( Indices::CONTENT_IDENTIFIER )
      return false unless key_map.contains?( Indices::INTER_SESSION_KEY_CRYPT )
      return false unless key_map.contains?( Indices::MASTER_COMMIT_ID )
      return true
    end



    SAFE_DATABASE_FOLDER   = File.join( Dir.home, ".safedb.net" )
    MASTER_CRYPTS_FOLDER   = File.join( SAFE_DATABASE_FOLDER, "safedb-master-crypts"   )
    SESSION_INDICES_FOLDER = File.join( SAFE_DATABASE_FOLDER, "safedb-session-indices" )
    SESSION_CRYPTS_FOLDER  = File.join( SAFE_DATABASE_FOLDER, "safedb-session-crypts"  )


  end


end
