#!/usr/bin/ruby

module SafeDb

  # Print out the secret key/value pairs. These are the ones with keys that start
  # with the @ sysmbol.
  class Tell < QueryVerse

    # Print out the secret key/value pairs. These are the ones with keys that start
    # with the @ sysmbol.
    def query_verse()

      @book.print_book_mark()
      if @verse.empty?()

        puts "No lines are in this chapter and verse location."
        puts ""
        return

      end

      show_map = {}
      @verse.each do | key_str, value |
        show_map.store( key_str, value ) if( key_str.start_with? "@" )
      end

      puts JSON.pretty_generate( show_map )
      puts ""

    end


  end


end
