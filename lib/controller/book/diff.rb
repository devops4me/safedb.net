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

      StateInspect.to_checkout_diff_report( book )

    end


  end


end
