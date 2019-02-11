#!/usr/bin/ruby
	
module SafeDb

  # The <b>init use case</b> initializes safe thus preparing it
  # for the ability to lock secrets, unlock them, transport their keys and
  # much more.
  #
  # safe is a <b>(glorified) placeholder</b>. It takes things in now,
  # keeps them safe and gives them back later, in a <b>helpful manner</b>.
  #
  # == Alternat Error Flows
  #
  # An error will be thrown
  #
  # - if safe cannot create, extend, read or write the drive folder
  # - if the domain is already in the configuration file
  # - if domain has non alphanums, excl hyphens, underscores, @ symbols, periods
  # - if domain does not begin or end with alphanums.
  # - if non alpha-nums (excl at signs) appear consecutively
  # - if no alpha-nums appear in the string
  # - if the domain string's length is less than 5
  # - if "safedb.net" appears twice (or more) in a directory tree
  #
  class Init < UseCase

    attr_writer :master_p4ss, :domain_name, :base_path


    # The init use case prepares the <b>safe</b> so that you can <b>open</b> an envelope,
    # <b>put</b> secrets into it and then <b>seal</b> (lock) it. Locking effectively writes
    # crypted blocks to both keystore and crypt store.
    def execute

      return unless ops_key_exists?

      KeyApi.init_app_domain( @domain_name, @base_path )
      keys_setup = KeyApi.is_domain_keys_setup?( @domain_name )

      if ( keys_setup )
        print_already_initialized
        return
      end

      domain_password = KeyPass.password_from_shell( true )
      KeyApi.setup_domain_keys( @domain_name, domain_password, create_header() )
      print_domain_initialized

# -->      unless @base_path.nil?
# -->        key_api.register_keystore( @base_path )
# -->      end

    end


    def pre_validation
    end


  end


end
