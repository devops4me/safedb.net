#!/usr/bin/ruby
	
module SafeDb

  # The <b>diff use case</b> spells out the key differences between the safe book
  # on the master line the one on the current working branch. There are two types
  # of diff - a refresh diff or a commit diff.
  #
  # == a refresh diff
  #
  # A refresh is effectively an incoming merge of the master's data
  # structure into the working branch. With refreshs nothing ever gets
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
  # == a commit diff
  #
  # A refresh merges whilst a commit is effectively a hard copy that destroys
  # whatever is on the master making it exactly reflect the branch's current state.
  #
  # The three addition state changes prophesized by a refresh can also occur on
  # commits. However commits can also prophesize that
  #
  # - this master's line value will be overwritten with the branch's value
  # - this chapter will be removed
  # - this verse will be removed
  # - this line will be removed
  #
  class Diff < Controller

    # The commit and refresh boolean flags that signal which way round to do the diff
    attr_writer :commit, :refresh

    # The <b>diff use case</b> compares the database state of the branch with
    # that of the master and displays the results without masking sensitive
    # credentials.
    def execute

      print_both = @commit.nil?() && @refresh.nil?()
      print_commit = !@commit.nil?() || print_both
      print_refresh = !@refresh.nil?() || print_both

      puts ""
      puts " == Birth Day := #{@book.init_time()}\n"
      puts " == Book Name := #{@book.book_name()} [#{@book.book_id}]\n"
      puts " == Book Mark := #{@book.get_open_chapter_name()}/#{@book.get_open_verse_name()}\n" if @book.is_opened?()
      puts ""

      master_data = @book.to_master_data()
      branch_data = @book.to_branch_data()

      StateInspect.refresh_prophecies( master_data, branch_data ) if print_refresh
      StateInspect.commit_prophecies( master_data, branch_data ) if print_commit

      puts ""
      puts "   master has #{master_data.length()} chapters, and #{@book.get_master_verse_count()} verses.\n"
      puts "   branch has #{branch_data.length()} chapters, and #{@book.get_branch_verse_count()} verses.\n"
      puts ""

    end


  end


end
