#!/usr/bin/ruby

module SafeDb

  # View provides a bird's eye view of the book's content and links well with
  # the <b>goto</b>, <b>show</b> and <b>tell</b> commands.
  #
  # View maps out and numbers each chapter/verse combination.
  # Goto with the number effectively shortcuts the open pinpointer.
  # Show prints out the verse lines at the opened path but masks any secrets.
  # Tell also prints out the verse lines but unabashedly displays secrets.
  class View < UseCase

    def execute

      book_index = BookIndex.new()
      is_opened = book_index.has_open_chapter_name?() && book_index.has_open_verse_name?()

      puts ""
      puts " == The Birthday := #{book_index.init_time()}\n"
      puts " == Book Name    := #{book_index.book_name()}\n"
      puts " == Book Mark    := #{book_index.get_open_chapter_name()}/#{book_index.get_open_verse_name()}\n" if is_opened
      puts " == No. Chapters := #{book_index.chapter_keys().length()}\n"
      puts ""

      verse_count = 0
      chapter_index = 0
      book_index.chapter_keys().each_pair do | chapter_name, chapter_keys |

        chapter_index += 1
        verse_index = 0
        chapter_data = Content.unlock_chapter( chapter_keys )
        chapter_data.each_key do | verse_name |

          verse_index += 1
          verse_count += 1
          is_open = book_index.is_open?( chapter_name, verse_name )
          isnt_first = verse_count != 1
          isnt_last = ( chapter_index != book_index.chapter_keys().length() ) || ( verse_index != chapter_data.length() )
          mark_open = is_open ? "<< " : ""
          mark_close = is_open ? " >>" : ""
          fixdint = format( "%02d", verse_count )
          puts " -- ---- --------------------------------------" if( is_open && isnt_first )
          puts " -- [#{fixdint}] #{mark_open}#{chapter_name} :~~ #{verse_name}#{mark_close}\n"
          puts " -- ---- --------------------------------------" if( is_open && isnt_last )

        end

      end

      puts ""
      puts " == There are #{book_index.chapter_keys().length()} chapters and #{verse_count} verses."
      puts ""

      return

    end


  end


end
