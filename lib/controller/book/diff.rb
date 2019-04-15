#!/usr/bin/ruby
	
module SafeDb

  # The <b>diff use case</b> spells out the key differences between the safe book
  # on the master line the one on the current working branch.
  # By default when conflicts occur, priority is given to the current working branch.
  class Diff < UseCase

    # The <b>diff use case</b> compares the database state of the branch with
    # that of the master and displays the results whilst masking sensitive
    # credentials.
  # By default when conflicts occur, priority is given to the current working branch.
    def execute

      book = Book.new()

      puts ""
      puts "### #############################################################\n"
      puts "--- -------------------------------------------------------------\n"
      puts ""
      puts " Book Name   := #{book.book_name()}\n"
      puts " Book Id     := #{book.book_id()}\n"
      puts ""

      puts JSON.pretty_generate( book.to_master_data() )

=begin
      new_verse_count = 0
      data_store = DataStore.from_json( File.read( @import_filepath ) )
      data_store.each_pair do | chapter_name, chapter_data |
        book.import_chapter( chapter_name, chapter_data )
        new_verse_count += chapter_data.length()
      end

      book.write()

      puts ""
      puts "#{data_store.length()} chapters and #{new_verse_count} verses were successfully imported.\n"
      puts ""
=end

    end


  end


end
