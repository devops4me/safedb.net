#!/usr/bin/ruby

module SafeDb

  # This master data structure controls the key publicly visible properties for
  # the safe database be it in a local or remote location.
  #
  # This object mapper seals away details of the persistence engine involved.
  # Who knows, it could be a local drive, an S3 bucket and even a database.
  class Master

    # Initialize an instance of this safe database's master properties.
    def initialize()
      @master = DataMap.new( Indices::MASTER_INDICES_FILEPATH )
    end


    # Get the coordinates (book, chapter and verse) of the verse that holds
    # the remote backend properties. An exception will be thrown if no backend
    # coordinates have been set.
    # @return [String] the backend coordinates to set
    def get_backend_coordinates()
      @master.use( Indices::REMOTE_MIRROR_SECTION_NAME )
      return @master.get( Indices::REMOTE_BACKEND_PROPERTIES_NAME )
    end


    # Set the coordinates (book, chapter and verse) of the verse that holds
    # the remote backend properties.
    # @param backend_coordinates [String] the backend coordinates to set
    def set_backend_coordinates( backend_coordinates )
      @master.use( Indices::REMOTE_MIRROR_SECTION_NAME )
      @master.set( Indices::REMOTE_BACKEND_PROPERTIES_NAME, backend_coordinates )
    end


  end


end
