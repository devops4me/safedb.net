#!/usr/bin/ruby
	
module SafeDb

  # The <b>diff use case</b> spells out the key differences between the safe book
  # on the master line the one on the current working branch.
  # By default when conflicts occur, priority is given to the current working branch.
  class Diff < UseCase

    # The <b>diff use case</b> compares the database state of the branch with
    # that of the master and displays the results without masking sensitive
    # credentials.
    def execute

      book = Book.new()

      puts ""
      puts " == Birth Day := #{book.init_time()}\n"
      puts " == Book Name := #{book.book_name()} [#{book.book_id}]\n"
      puts " == Book Mark := #{book.get_open_chapter_name()}/#{book.get_open_verse_name()}\n" if book.is_opened?()
      puts ""

      master_data = book.to_master_data()
      branch_data = book.to_branch_data()

      puts JSON.pretty_generate( master_data )
      puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
      puts JSON.pretty_generate( branch_data )

      puts ""
      puts "The master has #{master_data.length()} chapters and #{book.get_master_verse_count()} verses.\n"
      puts "The branch has #{branch_data.length()} chapters and #{book.get_branch_verse_count()} verses.\n"
      puts ""

    end


  end


end
