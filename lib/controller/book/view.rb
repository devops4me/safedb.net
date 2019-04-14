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

      book = Book.new()
      is_opened = book.has_open_chapter_name?() && book.has_open_verse_name?()

      puts ""
      puts " == The Birthday := #{book.init_time()}\n"
      puts " == Book Name    := #{book.book_name()}\n"
      puts " == Book Mark    := #{book.get_open_chapter_name()}/#{book.get_open_verse_name()}\n" if is_opened
      puts " == No. Chapters := #{book.branch_chapter_keys().length()}\n"
      puts ""

      verse_count = 0
      chapter_index = 0
      book.branch_chapter_keys().each_pair do | chapter_name, chapter_keys |

        chapter_index += 1
        verse_index = 0
        chapter_data = Content.unlock_chapter( chapter_keys )
        chapter_data.each_key do | verse_name |

          verse_index += 1
          verse_count += 1
          is_open = book.is_open?( chapter_name, verse_name )
          isnt_first = verse_count != 1
          isnt_last = ( chapter_index != book.branch_chapter_keys().length() ) || ( verse_index != chapter_data.length() )
          mark_open = is_open ? "<< " : ""
          mark_close = is_open ? " >>" : ""
          fixdint = format( "%02d", verse_count )
          puts " -- ---- --------------------------------------" if( is_open && isnt_first )
          puts " -- [#{fixdint}] #{mark_open}#{chapter_name} :~~ #{verse_name}#{mark_close}\n"
          puts " -- ---- --------------------------------------" if( is_open && isnt_last )

        end

      end

      puts ""
      puts " == There are #{book.branch_chapter_keys().length()} chapters and #{verse_count} verses."
      puts ""

      return

    end


  end


end
