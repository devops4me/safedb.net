#!/usr/bin/ruby
	
module SafeDb

  # The copy use case copies one or more chapters, one or more verses and
  # one or more lines to the clipboard so Ctrl-v can be used outside the
  # safe to paste data in (like complex passwords).
  #
  # Use {Drag} and {Drop} to move data between books, chapters, verses and
  # lines.
  #
  # Visit documentation at https://www.safedb.net/docs/copy-paste
  class Copy < QueryVerse

    # this entity can point to a book, chapter, verse or line. If no
    # parameter entity is provided, the --all switch must be present
    # to avoid an error message.
    attr_writer :line

    # The copy use case copies one or more chapters, one or more verses and
    # one or more lines to the clipboard so Ctrl-v can be used outside the
    # safe to paste data in (like complex passwords).
    def query_verse()

      @line = "@password" if @line.nil?
      unless ( @verse.has_key?( @line ) )
        cannot_copy_line()
        return
      end

      system "#{@verse[ @line ]} | xclip"
      system "#{@verse[ @line ]} | xclip -selection clipbaord"

    end


    def cannot_copy_line()

      puts ""
      puts "No parameter line to copy was given."
      puts "Also this verse does not have a @password line."
      puts ""

    end


  end


end
