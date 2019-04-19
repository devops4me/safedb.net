#!/usr/bin/ruby
	
module SafeDb

  # The <b>diff use case</b> spells out the key differences between the safe book
  # on the master line the one on the current working branch. There are two types
  # of diff - a checkout diff or a checkin diff.
  #
  # == a checkout diff
  #
  # A checkout is effectively an incoming merge of the master's data
  # structure into the working branch. With checkouts nothing ever gets
  # deleted.
  #
  # No delete is self-evident in this list of only <tt>4 prophetic</tt>
  # outcomes
  #
  # - this chapter will be added
  # - this verse will be added
  # - this line will be added
  # - this branch's line value will be overwritten with the value from master
  #
  # == a checkin diff
  #
  # A checkout merges whilst a checkin is effectively a hard copy that destroys
  # whatever is on the master making it exactly reflect the branch's current state.
  #
  # The three addition state changes prophesized by a checkout can also occur on
  # checkins. However checkins can also prophesize that
  #
  # - this master's line value will be overwritten with the branch's value
  # - this chapter will be removed
  # - this verse will be removed
  # - this line will be removed
  #
  class Diff < UseCase

    # The checkin and checkout boolean flags that signal which way round to do the diff
    attr_writer :checkin, :checkout

    # The <b>diff use case</b> compares the database state of the branch with
    # that of the master and displays the results without masking sensitive
    # credentials.
    def execute

      book = Book.new()

      print_both = @checkin.nil?() && @checkout.nil?()
      print_checkin = !@checkin.nil?() || print_both
      print_checkout = !@checkout.nil?() || print_both

      puts ""
      puts " == Birth Day := #{book.init_time()}\n"
      puts " == Book Name := #{book.book_name()} [#{book.book_id}]\n"
      puts " == Book Mark := #{book.get_open_chapter_name()}/#{book.get_open_verse_name()}\n" if book.is_opened?()
      puts ""

      master_data = book.to_master_data()
      branch_data = book.to_branch_data()

      StateInspect.checkout_prophecies( master_data, branch_data ) if print_checkout
      StateInspect.checkin_prophecies( master_data, branch_data ) if print_checkin

      puts ""
      puts "   master has #{master_data.length()} chapters, and #{book.get_master_verse_count()} verses.\n"
      puts "   branch has #{branch_data.length()} chapters, and #{book.get_branch_verse_count()} verses.\n"
      puts ""

    end


  end


end
