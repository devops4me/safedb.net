#!/usr/bin/ruby
	
module SafeDb

  # This idempotent <b>init use case</b> promises that a password-protected
  # book with the given name will exist within the safe's directory tree, along
  # with key derivation salts, ciphertext and other paraphernalia.
  #
  # After successful execution, the following state is observable
  #
  # - folder **`~/.safedb.net/safedb-master-crypts/safedb.book.<BOOK_ID>`** exists
  # - book content file **`safedb.chapter.<CONTENT_ID>.txt`** exists
  # - **`safedb-user-configuration.ini`** links the session and book ids
  # - **`safedb-master-index-local.ini`** has section with [<BOOK_ID>]
  #
  # Within the master index file in the [<BOOK_ID>] section will be
  #
  # - the book initialiize time
  # - the salts and ciphertext from the key derivation functions
  # - the ID and initialization vector (iv) of the contents file
  #
  # == init use case <b>pre-conditions</b>
  #
  # Warning or error messages must result unless these pre-conditions are met
  #
  # - a secret (if required) is prompted or in --password or SAFE_BOOK_PASSWORD
  # - the strength of the human sourced password is adequate
  # - the book name ( maybe from SAFE_BOOK_NAME ) follows convention
  # - the shell session must have a SAFE_TTY_TOKEN environment variable
  #
  class Init < AccessUc


    def execute

      @book_id = initialize_book()
      keys_setup = is_book_initialized?()

      if ( keys_setup )
        print_already_initialized
        return
      end

      book_secret = KeyPass.password_from_shell( true ) if @password.nil?
      book_secret = @password unless @password.nil?

      master_keys = KeyPair.new( MASTER_INDEX_LOCAL_FILE )
      master_keys.use( @book_id )

      KeyApi.recycle_keys(
        @book_name,
        book_secret,
        master_keys,
        create_header(),
        virgin_content()
      )

      print_domain_initialized

    end


    private


    def initialize_book()

      KeyError.not_new( @book_name, self )

      @book_id = KeyId.derive_app_instance_identifier( @book_name )

      keypairs = KeyPair.new( MASTER_INDEX_LOCAL_FILE )
      keypairs.use( @book_id )
      keypairs.set( "book.creation.time", KeyNow.readable() )

=begin
      session_identifier = KeyId.derive_session_id( to_token() )
      keypairs.use( "session.books" )
      keypairs.set( session_identifier, @book_id )


      # --
      # -- Switch the dominant application domain being used to
      # -- the domain that is being initialized right here.
      # --

SET THIS UP WHEN LOGIN HAPPENS - SIGNIFY THE SHELL SESSION BOOK USING 
      use_application_domain( @book_name )

=end

      return @book_id

    end


    def virgin_content()

      initial_db = KeyDb.new()
      initial_db.store( BOOK_CREATED_DATE, KeyNow.readable() )
      initial_db.store( BOOK_NAME, @book_name )
      initial_db.store( BOOK_ID, @book_id )
      initial_db.store( BOOK_CREATOR_VERSION, SafeDb::VERSION )

      return initial_db.to_json

    end


  end


end
