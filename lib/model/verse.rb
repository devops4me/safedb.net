#!/usr/bin/ruby

module SafeDb

  class Verse

    # Initialize a verse within a database, book and chapter location.
    #
    # @param the_bcv_name [String]
    #    this parameter should be a book/chapter/verse separated
    #    by forward slashes.
    def initialize( bcv_name )

      KeyError.not_new( bcv_name, self )
      coordinates = bcv_name.split( "/" )
      bcv_error_msg = "Invalid / separated book chapter and verse coordinate ~> #{bcv_name}"
      raise ArgumentError.new( bcv_error_msg ) unless coordinates.length() == 3
      
      @book_name = coordinates[ 0 ]
      @chapter_name = coordinates[ 1 ]
      @verse_name = coordinates[ 1 ]

      log.info(x) { "Initializing a book chapter and verse coordinate within book [#{@book_name}]." }

    end


  end


end
