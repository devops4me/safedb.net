#!/usr/bin/ruby
	
module SafeDb

  class Remote < Controller

    attr_writer :usecase

    def execute()

      is_create = usecase.eql?( "create" )
      return unless is_create

      repository_name = "safedb-crypts-#{TimeStamp.yyjjj_hhmm_sst()}"
      backend_properties = 


    end


  end


end
