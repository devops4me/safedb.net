#!/usr/bin/ruby
	
module SafeDb

  # The <b>remote use case</b> sets configuration so that the database backend
  # crypts can be pushed to a remote git repository and the corresponding master
  # indices can be pushed to an external (removable drive).
  #
  # The converse is also true thus allowing the local machine to mirror a remote
  # safe database that was either created or forwarded on another machine.
  class Remote < Controller

    attr_writer :directive_name, :directive_value

    # The <b>remote use case</b> sets configuration so that the database backend
    # crypts can be pushed to a remote git repository and the corresponding master
    # indices can be pushed to an external (removable drive).
    def execute()

      if directive_name.eql?( "folder" )

        folder_not_exists_msg = "Absolute folder path #{@directive_value} does not exist."
        folder_exists = (File.exist?( @directive_value )) && (File.directory?( @directive_value ))
        raise ArgumentError, folder_not_exists_msg unless folder_exists

        machine_config = DataMap.new( Indices::MACHINE_CONFIG_FILEPATH )
        machine_config.use( Indices::MACHINE_CONFIG_SECTION_NAME )
        machine_config.set( Indices::MACHINE_EXTERNAL_FOLDER_DIRECTIVE, @directive_value )

        puts ""
        puts "The external folder cradling the safe database indices is set."
        puts @direcitve_value
        puts ""

      end

    end


  end


end
