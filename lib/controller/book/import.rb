#!/usr/bin/ruby
	
module SafeDb

  # The <b>import use case</b> takes a filepath parameter in order to pull in
  # a <em>json</em> formatted data structure. It then proceeds to merge each
  # chapter of the source JSON structure into the corresponding chapter of
  # the destination, handling duplicate key/value pairs in a sensible way.
  #
  class Import < Controller

    attr_writer :import_filepath

    # The <b>import use case</b> takes a filepath parameter in order to pull in
    # a <em>json</em> formatted data structure. It then proceeds to merge each
    # chapter of the source JSON structure into the corresponding chapter of
    # the destination, handling duplicate key/value pairs in a sensible way.
    def execute

      abort "Cannot find the import file at path #{@import_filepath}" unless File.exists?( @import_filepath )

      puts ""
      puts "### #############################################################\n"
      puts "--- -------------------------------------------------------------\n"
      puts ""
      puts " Book Name   := #{@book.book_name()}\n"
      puts " Book Id     := #{@book.book_id()}\n"
      puts " Import from := #{@import_filepath}\n"
      puts " Import time := #{TimeStamp.readable()}\n"
      puts ""

      new_verse_count = 0
      data_store = DataStore.from_json( File.read( @import_filepath ) )
      data_store.each_pair do | chapter_name, chapter_data |
        @book.import_chapter( chapter_name, chapter_data )
        new_verse_count += chapter_data.length()
      end

      @book.write()

      puts ""
      puts "#{data_store.length()} chapters and #{new_verse_count} verses were successfully imported.\n"
      puts ""


    end


  end


end
