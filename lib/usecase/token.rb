#!/usr/bin/ruby

module SafeDb

  # The <tt>token use case</tt> prints out an encrypted session token tied
  # to the workstation and shell environment. See the root README.md on how
  # to export it and create a simple command alias for it in the ~/.bash_aliases
  # script which is executed when the shell starts.
  class Token < UseCase


    def execute

      print OpenKey::KeyLocal.generate_shell_key_and_token()

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

