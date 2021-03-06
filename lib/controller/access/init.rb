#!/usr/bin/ruby
	
module SafeDb

  # This idempotent <b>init use case</b> promises that a password-protected
  # book with the given name will exist within the safe's directory tree, along
  # with key derivation salts, ciphertext and other paraphernalia.
  #
  # Within the master index file in the [<BOOK_NAME>] section will be
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
  # - the shell must have a SAFE_TTY_TOKEN environment variable
  #
  class Init < Authenticate

    def execute

      if is_book_initialized?
        print_already_initialized
        return
      end

      EvolveState.create_book( @book_name )

      book_secret = KeyPass.password_from_shell( true ) if @password.nil?
      book_secret = @password unless @password.nil?

      master_keys = DataMap.new( FileTree.master_book_indices_filepath(@book_name ) )
      master_keys.use( @book_name )

      EvolveState.recycle_both_keys(
        @book_name,
        book_secret,
        master_keys,
        virginal_book()
      )

      commit_msg = "safe init artifacts for newly created (#{@book_name}) book on #{TimeStamp.readable()}."

      setup_git_repo(commit_msg)

      print_success_initializing

    end


    private

    def setup_git_repo(commit_msg)

      gitflow = GitFlow.new( FileTree.master_book_folder( @book_name ) )
      gitflow.init
      gitflow.config("#{ENV["USER"]}@#{Socket.gethostname()}", "SafeDb User")
      gitflow.stage()
      gitflow.list(false )
      gitflow.list(true)
      gitflow.commit( commit_msg )

    end


    def virginal_book()

      initial_db = DataStore.new()
      initial_db.store( Indices::SAFE_BOOK_INITIALIZE_TIME, TimeStamp.readable() )
      initial_db.store( Indices::SAFE_BOOK_NAME, @book_name )
      initial_db.store( Indices::SAFE_BOOK_INIT_VERSION, "#{Indices::SAFE_PRE_VERSION_STRING}#{SafeDb::VERSION}" )
      initial_db.store( Indices::SAFE_BOOK_CHAPTER_KEYS, {} )

      return initial_db.to_json

    end


    def print_already_initialized

      puts ""
      puts "You can go ahead and login."
      puts "Your book [#{@book_name}] already exists."
      puts "You should already know the password."
      puts ""
      puts "    #{COMMANDMENT} login #{@book_name}"
      puts ""

    end


    def print_success_initializing

      puts ""
      puts "Success! You can now login."
      puts "The book #{@book_name} has been created."
      puts "From now on you simply login like this."
      puts ""
      puts "    #{COMMANDMENT} login #{@book_name}"
      puts ""

    end


  end


end
