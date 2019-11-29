#!/usr/bin/ruby
	
module SafeDb

  # The <b>commit use case</b> commits any changes made to the safe book into
  # master. This is straightforward if the master's state has not been forwarded
  # by a ckeckin from another (shell) branch.
  #
  # The mechanics of a simple in-sync commit is to
  #
  # - sync the master crypts to exactly mimic the branch crypts
  # - tell master the content id of the book index file
  # - tell master what the current random iv (initialization vector) is
  # - create a new commit ID and set it on both master and branch
  # - set the master's last updated date and time
  #
  class Commit < Controller


    # The <b>commit use case</b> commits any changes made to the safe book into
    # master. This is straightforward if the master's state has not been forwarded
    # by a ckeckin from another (shell) branch.
    def execute

      @book.print_book_mark()

      unless @book.can_commit?()

        puts "Cannot commit as master has moved forward."
        puts "First see the difference, then refresh, and then commit."
        puts ""
        puts "   safe diff"
        puts "   safe refresh"
        puts "   safe commit"
        puts ""

        return

      end

      EvolveState.commit( @book )

      puts "Commit at #{TimeStamp.readable()} successful."
      puts ""


    end


  end


end
