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

      bcv_name = "#{@book_index.book_name()}/#{@book_index.get_open_chapter_name()}/#{@book_index.get_open_verse_name()}"

      puts ""
      puts "book/chapter/verse\n"
      puts "#{bcv_name} (#{@verse.length()})\n"
      puts ""

      if @verse.empty?()

## ==>        puts "There are no data lines in this verse."
## ==>        puts "Use the put command to add some."
## ==>        puts ""
## ==>        puts "safe put name \"Joe Bloggs\""
## ==>        puts "safe put email joe@safedb.net"
## ==>        puts "safe show"

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
