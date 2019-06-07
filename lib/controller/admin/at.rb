#!/usr/bin/ruby
	
module SafeDb

  # The <tt>at use case</tt> is all about opening books at the right page.
  # Its operation is similar to <tt>safe open</tt> and <tt>safe goto</tt>.
  #
  # It takes one and only one parameter which can consist of 1, 2 or 3 forward
  # slash separated parts.
  #
  #     $ safe at /contacts      # login or switch to the contacts book
  #     $ safe at /contacts/friends      # go to the friends chapter in contacts
  #     $ safe at /contacts/friends/paul # go to the paul verse in contacts
  #     $ safe at contacts/friends/paul  # the same as above
  #     $ safe at mary                   # if already in friends chapter
  #     $ safe at ../family/mum             # 
  #
  #
  class At < Controller

    # The chapter and verse of this book that are to be opened.
    attr_writer :chapter, :verse

    def execute

      @book.set_open_chapter_name( @chapter )
      @book.set_open_verse_name( @verse )
      @book.write()

      # Show the mini dictionary at the opened chapter and verse location
      # More work is needed when for when only the chapter is opened in
      # which case we should show the list of verses and perhaps the count
      # of key value pairs each verse contains.
      Show.new.flow()

    end


  end


end
