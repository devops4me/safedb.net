#!/usr/bin/ruby
	
module SafeDb

  # The <b>login use case</b> is given the domain name and if needs be
  # it collects the password then (if correct) logs the user in.
  #
  # Here are some key facts about the login command
  #
  # - its domain name parameter is mandatory
  # - it is called at the start of every branch
  # - it is undone by the logout command
  # - it requires the shell token environment variable to be set
  # - you can nest login commands thus using multiple domains
  # - you can call it with a --with=password switch
  # - a space before the command prevents it being logged in .bash_history
  # - you can deliver the password in multiple ways
  class Login < AccessUc


    def execute

# @todo usecase => in parent class Auth validate the book name

      @book_id = Identifier.derive_ergonomic_identifier( @book_name, Indices::SAFE_BOOK_ID_LENGTH )

      unless ( is_book_initialized?() )
        print_not_initialized
        return
      end

# @todo usecase => if logged in skip the password collection and do_login() function

# @todo usecase => search for password in environment variable

      book_password = KeyPass.password_from_shell( false ) if @password.nil?
      book_password = @password unless @password.nil?

# @todo usecase => if password is correct - if not print out an error.

      book_keys = DataMap.new( MASTER_INDEX_LOCAL_FILE )
      book_keys.use( @book_id )

      StateTransfer.login( book_keys, book_password )

      view_uc = View.new
      view_uc.flow_of_events

    end


    private


    def print_already_logged_in

      puts ""
      puts "We are already logged in. Open a secret envelope, put, then seal."
      puts ""
      puts "    #{COMMANDMENT} open aws.credentials:s3reader"
      puts "    #{COMMANDMENT} put access_key ABCD1234"
      puts "    #{COMMANDMENT} put secret_key FGHIJ56789"
      puts "    #{COMMANDMENT} put region_key eu-central-1"
      puts "    #{COMMANDMENT} seal"
      puts ""

    end


    def print_not_initialized

      puts ""
      puts "This book [ #{@book_name} ] has not yet been initialized."
      puts "Please initialize it with this command."
      puts ""
      puts "    #{COMMANDMENT} init #{@book_name}"
      puts ""

    end


  end


end


