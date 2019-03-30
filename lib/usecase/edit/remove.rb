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

      @chapter_data.delete_entry( @verse_id, @line_id )
      @chapter_data.delete_entry( @verse_id, "#{FILE_KEY_PREFIX}#{@line_id}" )

    end


  end


end
