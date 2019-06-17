#!/usr/bin/ruby
	
module SafeDb

  # The <b>configure use case</b> sets configuration so that the database backend
  # crypts can be pushed to a remote git repository and the corresponding master
  # indices can be pushed to an external (removable drive).
  #
  # The converse is also true thus allowing the local machine to mirror a remote
  # safe database that was either created or forwarded on another machine.
  class Configure < Controller

    attr_writer :directive_name, :directive_value

    # The <b>remote use case</b> sets configuration so that the database backend
    # crypts can be pushed to a remote git repository and the corresponding master
    # indices can be pushed to an external (removable drive).
    def execute()

      if @directive_name.eql?( Indices::MACHINE_REMOVABLE_DRIVE_PATH )

        folder_exists = File.exist?( @directive_value ) && File.directory?( @directive_value )
        unless folder_exists
          puts ""
          puts "Folder path => #{@directive_value}"
          puts "This path does not exist or it is not a folder."
          puts ""
          return
        end

        machine_config = DataMap.new( Indices::MACHINE_CONFIG_FILEPATH )
        machine_config.use( Indices::MACHINE_CONFIG_SECTION_NAME )
        machine_config.set( @directive_name, @directive_value )

        puts ""
        puts "The external safe database folder is set."
        puts @directive_value
        puts ""

        return

      end


      if( @directive_name.eql?( Indices::CONFIGURE_BACKEND_KEY_NAME ) )

        @book.set_open_chapter_name( @directive_value.split( "/" )[0].strip() )
        @book.set_open_verse_name( @directive_value.split( "/" )[1].strip() )
        @book.write()
        Master.new().set_backend_coordinates( "#{@book.book_id()}/#{@directive_value}" )
        Show.new.flow()

        puts ""
        puts "successfully set backend property coordinates"
        puts ""

        return

      end


      puts ""
      puts "Error. Remote config directive #{@directive_name} not recognized."
      puts "No changes were made."
      puts ""

    end


  end


end
