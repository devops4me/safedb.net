#!/usr/bin/ruby
	
module SafeDb

  # The <b>checkout use case</b> commits any changes made to the safe book into
  # master. This is straightforward if the master's state has not been forwarded
  # by a ckeckin from another (shell) branch.
  #
  # == master and branch not in sync
  #
  # Checkins cannot occur when the master's state has been moved forward by another
  # branch checkin. In these cases one needs to use the below sequence.
  #
  # - <tt>safe diff --checkout</tt> | diff will list what will the state changes during checkout
  # - <tt>safe checkout</tt> | the actual merge down (from master to branch) that never deletes keys
  # - <tt>safe checkin</tt> | now the checkin can proceed as the branch is in line with the master
  #
  # == checkout | merge up mechanics
  #
  # The mechanics of a simple in-sync checkout is to
  #
  # - sync the master crypts to exactly mimic the branch crypts
  # - tell master the content id of the book index file
  # - tell master what the current random iv (initialization vector) is
  # - create a new commit ID and set it on both master and branch
  # - set the master's last updated date and time
  #
  class CheckOut < UseCase


    # The <b>checkout use case</b> commits any changes made to the safe book into
    # master. This is straightforward if the master's state has not been forwarded
    # by a ckeckin from another (shell) branch.
    def execute

      book = Book.new()

      puts ""
      puts " == Birth Day := #{book.init_time()}\n"
      puts " == Book Name := #{book.book_name()} [#{book.book_id}]\n"
      puts " == Book Mark := #{book.get_open_chapter_name()}/#{book.get_open_verse_name()}\n" if book.is_opened?()
      puts ""

      StateMigrate.checkout( book )
      StateMigrate.copy_commit_id_to_branch( book )

      puts "Checkout from master to branch was successful.\n"
      puts ""


    end


  end


end
