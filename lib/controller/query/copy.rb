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

      log.info(x){ "Which Operating System is running? #{OpSys.get_host_os_string()}" }
      if( OpSys.is_mac_os?() )
        system "printf \"#{@verse[ @line ]}\" | pbcopy"
        line_copied()
        return
      end

      system "printf \"#{@verse[ @line ]}\" | xclip"
      system "printf \"#{@verse[ @line ]}\" | xclip -selection clipbaord"
      line_copied()

    end


    def line_copied()

      puts ""
      puts "The value for line \"#{@line}\" has been copied to the clipboard."
      puts "You can use Ctrl-v (or Command v on the Mac) to paste it."
      puts ""
      puts "Wipe it from the clipboard with $ safe wipe"
      puts ""

    end


    def cannot_copy_line()

      puts ""
      puts "No parameter line to copy was given."
      puts "Also this verse does not have a @password line."
      puts ""

    end


  end


end
