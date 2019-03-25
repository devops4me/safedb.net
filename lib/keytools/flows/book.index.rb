#!/usr/bin/ruby

module SafeDb

  # The book index is pretty much like the index at the front of a book!
  #
  # With a real book the index tells you the page number of a chapter. Here the index
  # tells us <b>contend id</b> of a chapter crypt file as well as the encryption key
  # and the random initialization vector required to decrypt the chapter's ciphertext.
  #
  # Most use cases will use this index to create, read, update and delete chapter
  # (and verse) data.
  class BookIndex

    # To read the book index we first find the appropriate shell key and the
    # appropriate book index ciphertext, one decrypts the other to produce the master
    # database decryption key which in turn reveals the JSON representation of the
    # master database.
    #
    # The {KeyMap} book index JSON is streamed into one of the crypt files denoted by
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
    def self.read()

      session_id = Identifier.derive_session_id( ShellSession.to_token() )
      session_indices_file = FilePath.session_indices_filepath( session_id )
      session_keys = KeyMap.new( session_indices_file )
      book_id = session_keys.read( Indices::SESSION_DATA, Indices::CURRENT_SESSION_BOOK_ID )
      session_keys.use( book_id )
      content_id = session_keys.get( Indices::CONTENT_IDENTIFIER )
      content_crypt_path = FilePath.session_crypts_filepath( book_id, session_id, content_id )

      crypt_txt = Lock.binary_from_read( content_crypt_path )

      crypt_key = content_crypt_key( session_keys )
      random_iv = KeyIV.in_binary( session_keys.get( Indices::CONTENT_RANDOM_IV ) )
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
    # <b>In with the new then out with the old</b>
    #
    # Once the new book index crypt file is written, the random iv and
    # content id are overwritten with the new values, and the old book
    # index crypt file is deleted.
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
    def self.write( content_header, app_database )

      session_id = Identifier.derive_session_id( ShellSession.to_token() )
      session_indices_file = FilePath.session_indices_filepath( session_id )
      session_keys = KeyMap.new( session_indices_file )
      book_id = session_keys.read( Indices::SESSION_DATA, Indices::CURRENT_SESSION_BOOK_ID )

      session_keys.use( book_id )

      old_content_id = session_keys.get( Indices::CONTENT_IDENTIFIER )
      old_content_crypt_path = FilePath.session_crypts_filepath( book_id, session_id, old_content_id )
      new_content_id = Identifier.get_random_identifier( Indices::CONTENT_ID_LENGTH )
      new_content_crypt_path = FilePath.session_crypts_filepath( book_id, session_id, new_content_id )

      iv_base64 = KeyIV.new().for_storage()
      random_iv = KeyIV.in_binary( iv_base64 )

      crypt_key = content_crypt_key( session_keys )

      binary_ciphertext = crypt_key.do_encrypt_text( random_iv, app_database.to_json )
      binary_to_write( new_content_crypt_path, content_header, binary_ciphertext )

      # The new book index file has been successfully written so we can now replace
      # the content id and random iv, then delete the old content crypt.

      session_keys.set( Indices::CONTENT_IDENTIFIER, new_content_id )
      session_keys.set( Indices::CONTENT_RANDOM_IV, iv_base64 )

    end


    private


    def self.content_crypt_key( session_keys )

      intra_key_ciphertext = session_keys.get( Indices::INTRA_SESSION_KEY_CRYPT )
      intra_key = KeyDerivation.regenerate_shell_key( ShellSession.to_token() )
      return intra_key.do_decrypt_key( intra_key_ciphertext )

    end


  end


end
