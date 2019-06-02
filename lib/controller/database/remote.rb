#!/usr/bin/ruby
	
module SafeDb

  # We want to provision (create) the safe's remote (github) backend.
  #
  # A number of setup tasks are executed when you ask that the backend repository be created.
  #
  # - a repository is created in github
  # - the git fetch (https) and git push (ssh) urls are fabricated
  # - the fetch url is written to the **`safedb-master-indices.ini`**
  # - the push url is written to the configured chapter/verse location
  # - a ssh public/private keypair (using EC25519) is created
  # - the private and public keys are placed within the chapter/verse
  # - the public (deploy) key is registered with the github repository
  #
  class Remote < Controller

    attr_writer :create

    # We want to provision (create) the safe's remote (github) backend.
    # A number of setup tasks are executed when you ask that the backend repository be created.
    def execute()

      return unless @create

      repository_name = "safedb-crypts-#{TimeStamp.yyjjj_hhmm_sst()}"
      backend_properties = Master.new().get_backend_coordinates()


    end


  end


end
