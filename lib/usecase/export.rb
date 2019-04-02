#!/usr/bin/ruby

module SafeDb

  # Export one, some or all chapters, verses and lines within the logged in book.
  #
  # == Aspirational Feature
  #
  # The --print flag demands that the exported text goes to stdout otherwise it
  # will be placed in an aptly named file in  the present working directory.
  class Export < UseCase

    def execute

      book_index = BookIndex.new()

      puts ""
      puts "### #############################################################\n"
      puts "--- --------------------------------------------------------------\n"
      puts ""
      puts " The Birthday := #{book_index.init_time()}\n"
      puts " Book Name    := #{book_index.book_name()}\n"
      puts " Book Id      := #{book_index.book_id()}\n"
      puts " Open Chapter := #{book_index.get_open_chapter_name()}\n" if book_index.has_open_chapter_name?()
      puts " Open Verse   := #{book_index.get_open_verse_name()}\n"   if book_index.has_open_verse_name?()
      puts ""

      export_filename = "safedb.#{book_index.book_id()}.#{KeyNow.yyjjj_hhmm_ss_nanosec()}.json"
      export_filepath = File.join( Dir.pwd, export_filename )

      exported_struct = {}
      verse_count = 0

      book_index.chapter_keys().each_pair do | chapter_name, chapter_keys |

        chapter_data = Content.unlock_chapter( chapter_keys )
        verse_count += chapter_data.length
        exported_struct.store( chapter_name, chapter_data )

      end

      File.write( export_filepath, JSON.pretty_generate( exported_struct ) )

      puts ""
      puts "Number of chapters exported >> #{book_index.chapter_count()}"
      puts "Number of verses exported >> #{verse_count}"
      puts "The export filename is #{export_filename}"
      puts "The Present Working Directory is #{Dir.pwd}"
      puts ""

      puts "--- --------------------------------------------------------------\n"
      puts "### #############################################################\n"
      puts ""


    end


  end


end
