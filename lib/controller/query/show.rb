#!/usr/bin/ruby

module SafeDb

  # Show the mini dictionary of key-value pairs within the logged in book
  # at the opened chapter and verse.
  #
  # If no dictionary exists at the opened chapter and verse a suitable
  # message is pushed out to the console.
  class Show < QueryVerse

    # We expect the book to be opened at a given chapter and verse location. This
    # use case simply (sensitively) shows the pertinent data lines contained within
    # the opened verse.
    def query_verse()

      @book.print_book_mark()
      if @verse.empty?()

        puts JSON.pretty_generate( {} )
        puts ""
        return

      end

      show_map = {}
      @verse.each do | key_str, value |

        is_file = key_str.start_with? Indices::INGESTED_FILE_LINE_NAME_KEY
        value.store( Indices::INGESTED_FILE_CONTENT64_KEY, Indices::SECRET_MASK_STRING ) if is_file
        show_map.store( key_str[ Indices::INGESTED_FILE_LINE_NAME_KEY.length() .. -1 ], value ) if is_file
        next if is_file

        is_secret = key_str.start_with? "@"
        showable_val = Indices::SECRET_MASK_STRING if is_secret
        showable_val = value unless is_secret
        show_map.store( key_str, showable_val )

      end

      puts JSON.pretty_generate( show_map )
      puts ""

    end


  end


end
