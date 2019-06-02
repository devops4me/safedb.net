#!/usr/bin/ruby

module SafeDb

  # Coordinates point to either a book, or a book/chapter or a book/chapter/verse
  # location. The location pointed to may or may not exist and even if they do they
  # may not be accessible if they exist within a book that (as of yet) we have not
  # logged into.
  class Coordinates


    # Initialize coordinates to a location within a book and/or chapter and/or verse.
    #
    # @param the_coordinates [String]
    #    this parameter should be a book/chapter/verse separated
    #    by forward slashes.
    def initialize( coordinates )

      KeyError.not_new( coordinates, self )
      coordinates = coordinates.split( "/" )
      bcv_error_msg = "Invalid / separated book chapter and verse coordinate ~> #{coordinates}"
      raise ArgumentError.new( bcv_error_msg ) unless coordinates.length() == 3
      
      @book_name = coordinates[ 0 ]
      @chapter_name = coordinates[ 1 ]
      @verse_name = coordinates[ 1 ]

      log.info(x) { "Initializing a book chapter and verse coordinate within book [#{@book_name}]." }

    end


    # Do the (book, chapter or verse) that our said coordinates point
    # to exist.
    def exists?()
    end


    # Do our coordinates point to an existing verse in a chapter within
    # the current logged in book.
    def is_verse?()
    end


    # Do our coordinates point to an existing chapter within the currently
    # logged in book.
    def is_chapter?()
    end


    # Do our coordinates point to any currently logged in book.
    def is_book?()
    end


  end


end
