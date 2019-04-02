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

      puts ""
      puts " The Birthday := #{book_index.init_time()}\n"
      puts " Book Name    := #{book_index.book_name()}\n"
      puts " Open Chapter := #{book_index.get_open_chapter_name()}\n" if book_index.has_open_chapter_name?()
      puts " Open Verse   := #{book_index.get_open_verse_name()}\n"   if book_index.has_open_verse_name?()
      puts ""

      goto_location = 1
      book_index.chapter_keys().each_pair do | chapter_name, chapter_keys |

        chapter_data = Content.unlock_chapter( chapter_keys )
        chapter_data.each_key do | verse_name |

          is_open = book_index.is_open?( chapter_name, verse_name )
          openend = is_open ? " (( open location ))" : ""
          fixdint = format( "%02d", goto_location )
          goindex = is_open ? "" : "[#{fixdint}] "
          puts " --- --- --------------------------------------" if is_open
          puts " --- #{goindex}#{chapter_name} ~> #{verse_name}#{openend}\n"
          puts " --- --- --------------------------------------" if is_open
          goto_location += 1

        end

      end

      puts ""

      return

    end


  end


end
