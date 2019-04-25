#!/usr/bin/ruby
	
module SafeDb

  # The <b>use <em>use case</em></b> borrowed from the database world denotes which
  # domain will be used <b>for now (and evermore)</b> on the workstation until another
  # use command is issued.
  #
  # == Observable Value
  #
  # The workstation configuration file will point to the domain name specified
  # marking it as the current and correct domain to use.
  #
  # == Alternative / Error Flows
  #
  # Error - if the domain name is not listed in the configuration file.
  # Error - if the (dictionary) path to the domain's base does not exist
  #
  class Use < Controller

    attr_writer :domain_name


    # The <b>use <em>use case</em></b> is borrowed from the database world and it denotes
    # the domain to be used <b>for now (and evermore)</b> for this workstation until another
    # use command is issued.
    #
    # The parameter domain_name must be set after an object instance is acquired but
    # before the execute method runs.
    def execute
    end


    def pre_validation
    end


  end


end
