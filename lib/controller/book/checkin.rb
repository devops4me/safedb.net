#!/usr/bin/ruby
	
module SafeDb

  # The <b>checkin use case</b> commits any changes made to the safe book into
  # master. This is straightforward if the master's state has not been forwarded
  # by a ckeckin from another (shell) branch.
  #
  # == master and branch not in sync
  #
  # The checkin and checkout use cases will be evolved to provide more options
  # if the master state is out of sync.
  #
  # Six options present when the master state is ahead.
  #
  # == first checkout and then checkin
  #
  # The preferred manner of dealing with an out of sync state is to checkout
  # first and then to checkin.
  #
  # - <tt>safe checkout --merge --branch</tt> | merge down (into branch) and branch wins on duplicates
  # - <tt>safe checkout --merge --master</tt> | merge down (into branch)  but master wins on duplicates
  # - <tt>safe checkout --clobber</tt>        | force branch to exactly mimic the master's state
  #
  # Once you chosent one of the above you can then <tt>safe checkin</tt> in a safe way.
  #
  # == bull in a china shop
  #
  # Merging down is more considered (and polite) to team members than merging up.
  # If you know what you are doing you can merge or clobber up!
  #
  # - <tt>safe checkin --merge --branch</tt> | merge up (into master) and branch wins on duplicates
  # - <tt>safe checkin --merge --master</tt> | merge up (into master) but master wins on duplicates
  # - <tt>safe checkin --clobber</tt>        | force master to exactly mimic our branch state
  #
  # == checkin | merge up mechanics
  #
  # The mechanics of a simple in-sync checkin is to
  #
  # - sync the master crypts to exactly mimic the branch crypts
  # - tell master the content id of the book index file
  # - tell master what the current random iv (initialization vector) is
  # - create a new commit ID and set it on both master and branch
  # - set the master's last updated date and time
  #
  class CheckIn < UseCase


    # The <b>checkin use case</b> commits any changes made to the safe book into
    # master. This is straightforward if the master's state has not been forwarded
    # by a ckeckin from another (shell) branch.
    def execute

      book = Book.new()
      book.print_book_mark()

      unless book.can_checkin?()

        puts "Cannot checkin as master has moved forward."
        puts "First see the difference, then checkout, and then checkin."
        puts ""
        puts "   safe diff"
        puts "   safe checkout"
        puts "   safe checkin"
        puts ""
        return

      end

      StateMigrate.checkin( book )

      puts "The checkin was on #{KeyNow.readable()}\n"
      puts "Checkin from branch to master was successful.\n"
      puts ""


    end


  end


end
