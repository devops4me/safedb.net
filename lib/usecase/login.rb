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
  class Login < UseCase

    attr_writer :password, :domain_name


    def execute

      return unless ops_key_exists?

      unless ( KeyApi.is_domain_keys_setup?( @domain_name ) )
        print_not_initialized
        return
      end

############## Call [[ KeyApi.is_logged_in? ]] - then print msg and skip password collection below
############## Call [[ KeyApi.is_logged_in? ]] - then print msg and skip password collection below
############## Call [[ KeyApi.is_logged_in? ]] - then print msg and skip password collection below
############## Call [[ KeyApi.is_logged_in? ]] - then print msg and skip password collection below
############## Call [[ KeyApi.is_logged_in? ]] - then print msg and skip password collection below
############## Call [[ KeyApi.is_logged_in? ]] - then print msg and skip password collection below

      domain_secret = KeyPass.password_from_shell( false ) if @password.nil?
      domain_secret = @password unless @password.nil?

############## Use [[ KeyApi.valid_password? ]] and give error if not valid
############## Use [[ KeyApi.valid_password? ]] and give error if not valid
############## Use [[ KeyApi.valid_password? ]] and give error if not valid
############## Use [[ KeyApi.valid_password? ]] and give error if not valid
############## Use [[ KeyApi.valid_password? ]] and give error if not valid

      KeyApi.do_login( @domain_name, domain_secret, create_header() )

      view_uc = View.new
      view_uc.flow_of_events

    end


    # Perform pre-conditional validations in preparation to executing the main flow
    # of events for this use case. This method may throw the below exceptions.
    #
    # @raise [SafeDirNotConfigured] if the safe's url has not been configured
    # @raise [EmailAddrNotConfigured] if the email address has not been configured
    # @raise [StoreUrlNotConfigured] if the crypt store url is not configured
    def pre_validation

    end


  end


end


