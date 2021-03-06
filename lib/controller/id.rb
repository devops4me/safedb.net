#!/usr/bin/ruby
	
module SafeDb


  class Id < Controller


    def execute

      puts ""
      puts TimeStamp.grab()
      puts TimeStamp.fetch()
      puts ""

      return

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
