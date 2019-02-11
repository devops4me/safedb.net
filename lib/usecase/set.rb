#!/usr/bin/ruby
	
module SafeDb

  # The <b>set <em>use case</em></b> is the generic tool for setting configuration
  # directives inside the safe workstation INI formatted file.
  #
  # The mirror of this use case is <b><em>unset</em></b>.
  #
  # == Observable Value
  #
  # The configuration directive will eithe be created (or will overwrite) an existing
  # directive with the same path.
  #
  # The configuration file is printed to inform the user of the current state.
  #
  # == Alternative / Error Flows
  #
  # Error - if the directive path is not composed of two (fwd slash separated) parts
  # Error - if the directive path and/or value contains (or not) unacceptable characters
  #
  class Set < UseCase

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
