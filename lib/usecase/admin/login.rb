#!/usr/bin/ruby
	
module SafeDb

  # The <b>login use case</b> is given the domain name and if needs be
  # it collects the password then (if correct) logs the user in.
  #
  # Here are some key facts about the login command
  #
  # - its domain name parameter is mandatory
  # - it is called at the start of every session
  # - it is undone by the logout command
  # - it requires the shell token environment variable to be set
  # - you can nest login commands thus using multiple domains
  # - you can call it with a --with=password switch
  # - a space before the command prevents it being logged in .bash_history
  # - you can deliver the password in multiple ways
  class Login < AccessUc


    def execute

      @book_id = Identifier.derive_app_instance_identifier( @book_name )

      unless ( is_book_initialized?() )
        print_not_initialized
        return
      end

############## Call [[ KeyApi.is_logged_in? ]] - then print msg and skip password collection below
############## Call [[ KeyApi.is_logged_in? ]] - then print msg and skip password collection below
############## Call [[ KeyApi.is_logged_in? ]] - then print msg and skip password collection below
############## Call [[ KeyApi.is_logged_in? ]] - then print msg and skip password collection below
############## Call [[ KeyApi.is_logged_in? ]] - then print msg and skip password collection below
############## Call [[ KeyApi.is_logged_in? ]] - then print msg and skip password collection below

      book_password = KeyPass.password_from_shell( false ) if @password.nil?
      book_password = @password unless @password.nil?

############## Use [[ KeyApi.valid_password? ]] and give error if not valid
############## Use [[ KeyApi.valid_password? ]] and give error if not valid
############## Use [[ KeyApi.valid_password? ]] and give error if not valid
############## Use [[ KeyApi.valid_password? ]] and give error if not valid
############## Use [[ KeyApi.valid_password? ]] and give error if not valid

      book_keys = KeyMap.new( MASTER_INDEX_LOCAL_FILE )
      book_keys.use( @book_id )

      LoginOut.do_login( book_keys, book_password, create_header() )

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


