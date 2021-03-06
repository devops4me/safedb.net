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

  # - an environment variable
  # - the system clipboard (cleared after reading)
  # - a file whose path is a command parameter
  # - a file in a pre-agreed location
  # - a file in the present directory (with a pre-agreed name)
  # - a URL from a parameter or pre-agreed
  # - the shell's secure password reader
  class Login < Authenticate

    # If the clip switch is present it signifies that the password should
    # be read in from the clipboard. Any text selection puts text into the
    # the clipboard - no need specifically to use Ctrl-c (copy).
    attr_writer :clip

    # The view of chapter and verse names within the book is not printed out
    # after a successful login if this suppress_output flag is set to true.
    attr_writer :suppress_output

    def execute

      unless ( is_book_initialized?() )
        print_not_initialized
        return
      end

      if( StateInspect.is_logged_in?( @book_name ) )
        EvolveState.use_book( @book_name )
        View.new().flow() unless @suppress_output
        return
      end

      book_password = Clipboard.read_password() if @clip
      book_password = KeyPass.password_from_shell( false ) if( @password.nil?() && !@clip )
      book_password = @password unless @password.nil?()

      book_keys = DataMap.new( FileTree.master_book_indices_filepath(@book_name ) )
      book_keys.use( @book_name )
      is_login_successful = EvolveState.login( @book_name, book_keys, book_password )
      print_login_failure() unless is_login_successful
      return unless is_login_successful

      View.new().flow() unless @suppress_output

    end


    private


    def print_login_failure()

      puts ""
      puts "The login into book [ #{@book_name} ] has failed."
      puts "Please check the book name and password combination."
      puts "Also visit login docs on how to present passwords."
      puts ""

    end


    def print_not_initialized()

      puts ""
      puts "This book [ #{@book_name} ] has not yet been initialized."
      puts "Please initialize it with this command."
      puts ""
      puts "    #{COMMANDMENT} init #{@book_name}"
      puts ""

    end


  end


end


