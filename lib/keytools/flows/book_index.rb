#!/usr/bin/ruby

module SafeDb

  # The book index is pretty much like the index at the front of a book!
  #
  # With a real book the index tells you the page number of a chapter. Our BookIndex
  # knows about and behaves with concepts like
  #
  # - the list of chapters in the book including the chapter names
  # - attributes like book name, creation and last accessed dates
  # - book scoped configuration directives and their values
  # - chapter keys including file content ids and encryption keys
  #
  # Parental use cases in the background will use this index to encrypt, decrypt
  # create, read, update and delete chapter encased credentials.
  #
  class BookIndex


    # Initialize the book index data structure from the session state file
    # and the current session identifier.
    #
    # We assume that something else created the very first book index so we
    # never check whether it exists, instead we assume that one does exist.
    def initialize

      @session_id = Identifier.derive_session_id( ShellSession.to_token() )
      session_indices_file = FileTree.session_indices_filepath( @session_id )
      @session_keys = KeyMap.new( session_indices_file )
      @book_id = @session_keys.read( Indices::SESSION_DATA, Indices::CURRENT_SESSION_BOOK_ID )
      @session_keys.use( @book_id )
      @content_id = @session_keys.get( Indices::CONTENT_IDENTIFIER )

      intra_key_ciphertext = @session_keys.get( Indices::INTRA_SESSION_KEY_CRYPT )
      intra_key = KeyDerivation.regenerate_shell_key( ShellSession.to_token() )
      @crypt_key = intra_key.do_decrypt_key( intra_key_ciphertext )

      read()

    end


    # Construct a BookIndex object that extends the KeyStore data structure
    # which in turns extens the Ruby hash object. The parental objects know
    # how to manipulate (store, delete, read etc the data structures).
    #
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
    def read()

      read_crypt_path = FileTree.session_crypts_filepath( @book_id, @session_id, @content_id )
      random_iv = KeyIV.in_binary( @session_keys.get( Indices::CONTENT_RANDOM_IV ) )
      @book_index = KeyStore.from_json( Content.unlock_it( read_crypt_path, @crypt_key, random_iv ) )

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
    def write()

      old_crypt_path = FileTree.session_crypts_filepath( @book_id, @session_id, @content_id )

      @content_id = Identifier.get_random_identifier( Indices::CONTENT_ID_LENGTH )
      @session_keys.set( Indices::CONTENT_IDENTIFIER, @content_id )
      write_crypt_path = FileTree.session_crypts_filepath( @book_id, @session_id, @content_id )

      iv_base64 = KeyIV.new().for_storage()
      @session_keys.set( Indices::CONTENT_RANDOM_IV, iv_base64 )
      random_iv = KeyIV.in_binary( iv_base64 )

      Content.lock_it( write_crypt_path, @crypt_key, random_iv, @book_index.to_json, TextChunk.crypt_header( @book_id ) )
      File.delete( old_crypt_path ) if File.exists? old_crypt_path

    end


    # Return true if this book has been opened at a chapter and verse location.
    # This method uses {print_open_help} to print out a helpful message detailing
    # how to open a chapter and verse.
    #
    # Note that an open chapter need not contain any data. The same goes for an
    # open verse. In these cases the {open_chapter} and {open_verse} methods both
    # return empty data structures.
    def unopened_chapter_verse()
      return if has_open_chapter?() and has_open_verse?()
      print_open_help()
    end


    # Returns true if this book index has a chapter name specified to be the
    # open chapter. True is returned even if the open chapter data structure
    # is empty.
    def has_open_chapter?()
      return @book_index.has_key?( Indices::OPENED_CHAPTER_NAME )
    end


    # Returns true if this book index has a verse name specified to be the
    # open verse. True is returned even if the open verse data structure is
    # empty.
    def has_open_verse?()
      return @book_index.has_key?( Indices::OPENED_VERSE_NAME )
    end


    # Returns the name of the chapter that this book has been opened at.
    # If has_open_chapter?() returns false this method will throw an exception.
    def chapter_name()
      abort "No chapter has been opened." unless has_open_chapter?()
      return @book_index[ Indices::OPENED_CHAPTER_NAME ]
    end


    # Returns the name of the verse that this book has been opened at.
    # If has_open_verse?() returns false this method will throw an exception.
    def verse_name()
      abort "No verse has been opened." unless has_open_verse?()
      return @book_index[ Indices::OPENED_VERSE_NAME ]
    end


    private


    def print_open_help()

      <<-UNOPENED_MESSAGE

      Please open a chapter and verse to put, edit or query data.

          #{COMMANDMENT} open contacts monica

       then add monica's contact details

          #{COMMANDMENT} put email monica.lewinsky@gmail.com
          #{COMMANDMENT} put phone +1-357-246-8901
          #{COMMANDMENT} put twitter @monica_x
          #{COMMANDMENT} put skype.id 6363430539
          #{COMMANDMENT} put birthday \"1st April 1978\"

       also hilary's

          #{COMMANDMENT} open contacts hilary
          #{COMMANDMENT} put email hilary@whitehouse.gov

       then save the changes to your book and logout."

          #{COMMANDMENT} commit"
          #{COMMANDMENT} logout"

      UNOPENED_MESSAGE

    end


  end


end
