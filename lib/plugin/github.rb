#!/usr/bin/ruby

module SafeDb

  # This class knows how to talk to Github and callers can delegate common
  # github functionality like creating repositories, listing repositories,
  # downloading repositories and the like.
  #
  class Github

    # Initialize an instance of this safe database's master properties.
    def initialize()




      #
      #
      #  Test the Github api using curl
      #
      #
      #       curl -H "Authorization: token OAUTH-TOKEN" https://api.github.com
      #
      #


      @master = DataMap.new( Indices::MASTER_INDICES_FILEPATH )
    end


    # Get the coordinates (book, chapter and verse) of the verse that holds
    # the remote backend properties. An exception will be thrown if no backend
    # coordinates have been set.
    # @return [String] the backend coordinates to set
    def get_backend_coordinates()
      @master.use( Indices::REMOTE_MIRROR_SECTION_NAME )
      return @master.get( Indices::REMOTE_MIRROR_PAGE_NAME )
    end


    # Set the coordinates (book, chapter and verse) of the verse that holds
    # the remote backend properties.
    # @param backend_coordinates [String] the backend coordinates to set
    def set_backend_coordinates( backend_coordinates )
      @master.use( Indices::REMOTE_MIRROR_SECTION_NAME )
      @master.set( Indices::REMOTE_MIRROR_PAGE_NAME, backend_coordinates )
    end


  end


end
