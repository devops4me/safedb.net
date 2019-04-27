#!/usr/bin/ruby
	
module SafeDb

  # The <tt>remove</tt> use case takes away one or more of the safe's core entities.
  #
  # - at <tt>verse</tt> level - it can delete one or more lines
  # - at <tt>chapter</tt> level - it can delete one or more verses
  # - at <tt>book</tt> level - it can delete one or more chapters
  # - at <tt>safe</tt> level - it can delete one book
  #
  class Remove < EditVerse

    attr_writer :line_id

    # Deletion that currently expects an open chapter and verse and always
    # wants to delete only one line (key/value pair).
    def edit_verse()

      # @todo refactor to recognise file values using isMap rather than the string prefix
      # @todo refactor the Rename, Show, Read and Write use cases as well as this one.

      @verse.delete( @line_id )
      @verse.delete( "#{Indices::INGESTED_FILE_LINE_NAME_KEY}#{@line_id}" )

    end


  end


end
