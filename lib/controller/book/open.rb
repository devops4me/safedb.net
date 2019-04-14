#!/usr/bin/ruby
	
module SafeDb

  # The <tt>open use case</tt> allows us to add (put), subtract (remove), change
  # (update) and list the credential within first a chapter (outer) and then within
  # a verse (inner), of the logged in book.
  #
  # == safe reopen <<chapter>> <<verse>>
  #
  # If you need to be sure that you are re-opening a chapter and verse that already
  # exists you use the <tt>safe reopen</tt> command. This command produces an error
  # if it cannot find specified chapter and verse.
  #
  class Open < UseCase

    # The chapter and verse of this book that are to be opened.
    attr_writer :chapter, :verse

    def execute

      book = Book.new()
      book.set_open_chapter_name( @chapter )
      book.set_open_verse_name( @verse )
      book.write()

      # Show the mini dictionary at the opened chapter and verse location
      # More work is needed when for when only the chapter is opened in
      # which case we should show the list of verses and perhaps the count
      # of key value pairs each verse contains.
      Show.new.flow_of_events

    end


  end


end
