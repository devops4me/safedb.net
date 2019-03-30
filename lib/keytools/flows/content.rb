#!/usr/bin/ruby

module SafeDb

  # This class both locks content, writing the ciphertext to a file, and
  # unlocks content after reading ciphertext from a file.
  #
  # It supports the encryption of large bodies of text or binary because
  # it uses the efficient and effective AES asymmetric algorithm.
  #
  class Content


    # Lock the content body provided - place the resulting ciphertext
    # inside a file named by a random identifier, then write this identifier
    # along wih the initialization and encryption key into the provided
    # key-value map (hash).
    #
    # The content ciphertext derived from encrypting the body is stored
    # in a file underneath the provided content header.
    #
    # @param book_id [String] used to determine the book's master crypt folder
    # @param crypt_key [Key] the key used to (symmetrically) encrypt the content provided
    # @param key_store [KeyMap] either KeyMap or KeyStore containing the content id and random iv
    # @param content_body [String] content to encryt and the ciphertext will be stored
    # @param content_header [String] string that tops and tails the content's ciphertext
    def self.lock_master( book_id, crypt_key, key_store, content_body, content_header )

      content_id = Identifier.get_random_identifier( Indices::CONTENT_ID_LENGTH )
      key_store.set( Indices::CONTENT_IDENTIFIER, content_id )
      master_crypt_path = FileTree.master_crypts_filepath( book_id, content_id )
      iv_base64 = KeyIV.new().for_storage()
      key_store.set( Indices::CONTENT_RANDOM_IV, iv_base64 )
      random_iv = KeyIV.in_binary( iv_base64 )

      lock_it( master_crypt_path, crypt_key, random_iv, content_body, content_header )

    end



    # Lock the content body provided - place the resulting ciphertext
    # inside a file named by a random identifier, then write this identifier
    # along wih the initialization and encryption key into the provided
    # key-value map (hash).
    #
    # The content ciphertext derived from encrypting the body is stored
    # in a file underneath the provided content header.
    #
    # @param key_store [KeyMap] either KeyMap or KeyStore containing the content id and random iv
    # @param content_body [String] content to encryt and the ciphertext will be stored
    # @param content_header [String] string that tops and tails the content's ciphertext
    def self.lock_chapter( key_store, content_body, content_header )

      session_id = Identifier.derive_session_id( ShellSession.to_token() )
      session_indices_file = FileTree.session_indices_filepath( session_id )
      book_id = KeyMap.new( session_indices_file ).read( Indices::SESSION_DATA, Indices::CURRENT_SESSION_BOOK_ID )

      old_content_id = key_store[ Indices::CONTENT_IDENTIFIER ] if key_store.has_key?(Indices::CONTENT_IDENTIFIER)

      new_content_id = Identifier.get_random_identifier( Indices::CONTENT_ID_LENGTH )
      key_store.store( Indices::CONTENT_IDENTIFIER, new_content_id )

      new_chapter_crypt_path = FileTree.session_crypts_filepath( book_id, session_id, new_content_id )

      iv_base64 = KeyIV.new().for_storage()
      key_store.store( Indices::CONTENT_RANDOM_IV, iv_base64 )
      random_iv = KeyIV.in_binary( iv_base64 )

      crypt_key = Key.from_random()
      key_store.store( Indices::CHAPTER_KEY_CRYPT, crypt_key.to_char64() )

      lock_it( new_chapter_crypt_path, crypt_key, random_iv, content_body, content_header )

      unless old_content_id.nil?
        old_chapter_crypt_path = FileTree.session_crypts_filepath( book_id, session_id, old_content_id )
        File.delete( old_chapter_crypt_path )
      end

    end



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
    # @param crypt_path [File] path to the crypt file holding the encrypted ciphertext
    # @param crypt_key [Key] the key used to (symmetrically) encrypt the content provided
    # @param random_iv [String] the random initialization vector for the encryption
    # @param content_body [String] content to encryt and the ciphertext will be stored
    # @param content_header [String] string that tops and tails the content's ciphertext
    def self.lock_it( crypt_path, crypt_key, random_iv, content_body, content_header )

      binary_ctext = crypt_key.do_encrypt_text( random_iv, content_body )
      binary_to_write( crypt_path, content_header, binary_ctext )

    end



    # Use the content's external id to find the ciphertext file that is to be unlocked.
    # Then use the unlock key from the parameter along with the random IV that is inside
    # the {KeyMap} or {KeyStore} to decrypt and return the ciphertext.
    #
    # @param unlock_key [Key] symmetric key that was used to encrypt the ciphertext
    # @param key_store [KeyMap] either {KeyMap} or {KeyStore} containing content id and random iv
    # @return [String] the resulting decrypted text that was encrypted with the parameter key
    def self.unlock_master( unlock_key, key_store )

      book_id = key_store.section()
      crypt_path = FileTree.master_crypts_filepath( book_id, key_store.get( Indices::CONTENT_IDENTIFIER ) )
      random_iv = KeyIV.in_binary( key_store.get( Indices::CONTENT_RANDOM_IV ) )
      return unlock_it( crypt_path, unlock_key, random_iv )

    end



    # Use the content's external id to find the ciphertext file that is to be unlocked.
    # Then use the unlock key from the parameter along with the random IV that is inside
    # the {KeyMap} or {KeyStore} to decrypt and return the ciphertext.
    #
    # @param unlock_key [Key] symmetric key that was used to encrypt the ciphertext
    # @param key_store [KeyMap] either {KeyMap} or {KeyStore} containing content id and random iv
    # @return [String] the resulting decrypted text that was encrypted with the parameter key
    def self.unlock_chapter( key_store )

      session_id = Identifier.derive_session_id( ShellSession.to_token() )
      session_indices_file = FileTree.session_indices_filepath( session_id )
      book_id = KeyMap.new( session_indices_file ).read( Indices::SESSION_DATA, Indices::CURRENT_SESSION_BOOK_ID )

      content_id = key_store[ Indices::CONTENT_IDENTIFIER ]
      crypt_key = Key.from_char64( key_store[ Indices::CHAPTER_KEY_CRYPT ] )
      random_iv = KeyIV.in_binary( key_store[ Indices::CONTENT_RANDOM_IV ] )

      crypt_path = FileTree.session_crypts_filepath( book_id, session_id, content_id )
      return KeyStore.from_json( unlock_it( crypt_path, crypt_key, random_iv ) )

    end



    # Use the content's external id to find the ciphertext file that is to be unlocked.
    # Then use the unlock key from the parameter along with the random IV that is inside
    # the {KeyMap} or {KeyStore} to decrypt and return the ciphertext.
    #
    # @param crypt_path [File] path to the crypt file holding the encrypted ciphertext
    # @param unlock_key [Key] symmetric key that was used to encrypt the ciphertext
    # @param random_iv [String] the random initialization vector for the encryption
    # @return [String] the resulting decrypted text that was encrypted with the parameter key
    def self.unlock_it( crypt_path, unlock_key, random_iv )

      crypt_txt = binary_from_read( crypt_path )
      text_data = unlock_key.do_decrypt_text( random_iv, crypt_txt )

      return text_data

    end


    private


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


  end


end
