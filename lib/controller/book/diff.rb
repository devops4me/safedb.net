#!/usr/bin/ruby
	
module SafeDb

  # The <b>diff use case</b> compares the database state of the branch with
  # that of the master and displays the results whilst masking sensitive
  # credentials.
  #
  class Diff < UseCase

    # The <b>diff use case</b> compares the database state of the branch with
    # that of the master and displays the results whilst masking sensitive
    # credentials.
    def execute

      book_index = BookIndex.new()

      abort "Cannot find the import file at path #{@import_filepath}" unless File.exists?( @import_filepath )

      puts ""
      puts "### #############################################################\n"
      puts "--- -------------------------------------------------------------\n"
      puts ""
      puts " Book Name   := #{book_index.book_name()}\n"
      puts " Book Id     := #{book_index.book_id()}\n"
      puts " Import from := #{@import_filepath}\n"
      puts " Import time := #{KeyNow.readable()}\n"
      puts ""

      new_verse_count = 0
      data_store = DataStore.from_json( File.read( @import_filepath ) )
      data_store.each_pair do | chapter_name, chapter_data |
        book_index.import_chapter( chapter_name, chapter_data )
        new_verse_count += chapter_data.length()
      end

      book_index.write()

      puts ""
      puts "#{data_store.length()} chapters and #{new_verse_count} verses were successfully imported.\n"
      puts ""


    end


  end


end
