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

      @book_id = Identifier.derive_app_instance_identifier( @book_name )

      if is_book_initialized?()
        print_already_initialized
        return
      end

      initialize_book()

      book_secret = KeyPass.password_from_shell( true ) if @password.nil?
      book_secret = @password unless @password.nil?

      master_keys = KeyMap.new( MASTER_INDEX_LOCAL_FILE )
      master_keys.use( @book_id )

      KeyCycle.recycle(
        @book_id,
        book_secret,
        master_keys,
        create_header(),
        virgin_content()
      )

      print_success_initializing

    end


    private


    def initialize_book()

      Lock.create_master_book_crypts_folder( @book_id )

      keypairs = KeyMap.new( MASTER_INDEX_LOCAL_FILE )
      keypairs.use( @book_id )
      keypairs.set( "book.creation.time", KeyNow.readable() )
      keypairs.set( Indices::MASTER_COMMIT_ID,  Identifier.get_random_identifier( 16 ) )


    end


    def virgin_content()

      initial_db = KeyStore.new()
      initial_db.store( BOOK_CREATED_DATE, KeyNow.readable() )
      initial_db.store( BOOK_NAME, @book_name )
      initial_db.store( BOOK_ID, @book_id )
      initial_db.store( BOOK_CREATOR_VERSION, SafeDb::VERSION )

      return initial_db.to_json

    end


    def print_already_initialized

      puts ""
      puts "You can go ahead and login."
      puts "Your domain [#{@book_name}] is already setup."
      puts "You should already know the password."
      puts ""
      puts "    #{COMMANDMENT} login #{@book_name}"
      puts ""

    end


    def print_success_initializing

      puts ""
      puts "Success! You can now login."
      puts "Your book #{@book_name} with id #{@book_id} is up."
      puts "From now on you simply login like this."
      puts ""
      puts "    #{COMMANDMENT} login #{@book_name}"
      puts ""

    end


  end


end
