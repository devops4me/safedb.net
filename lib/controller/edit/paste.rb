#!/usr/bin/ruby
	
module SafeDb

  # Paste the current clipboard or selection text into the specified line
  # at the current book's open chapter and verse.
  #
  # Sensitive values now neither need to be put on the commnad line (safe put)
  # or inputted perhaps with a typo when using (safe input).
  # 
  # Use <b>safe wipe</b> to wipe (overwrite) any sensitive values that has
  # been placed on the clipboard.
  class Paste < EditVerse

    # this entity can point to a book, chapter, verse or line. If no
    # parameter entity is provided, the --all switch must be present
    # to avoid an error message.
    attr_writer :line

    # The paste use case places a string from the clipboard into the
    # specified line (@password is the default if no line name is specified).
    def edit_verse()

      @line = "@password" if @line.nil?
      @verse.store( "#{@line}-#{TimeStamp.yyjjj_hhmm_sst()}", @verse[ @line ] ) if @verse.has_key?( @line )

      clipboard_text = Clipboard.read_line()
      @verse.store( @line, clipboard_text )

    end


  end


end
