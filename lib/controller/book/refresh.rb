#!/usr/bin/ruby
	
module SafeDb

  # The <b>refresh use case</b> commits any changes made to the safe book into
  # master. This is straightforward if the master's state has not been forwarded
  # by a ckeckin from another (shell) branch.
  #
  # == master and branch not in sync
  #
  # Commits cannot occur when the master's state has been moved forward by another
  # branch commit. In these cases one needs to use the below sequence.
  #
  # - <tt>safe diff --refresh</tt> | diff will list what will the state changes during refresh
  # - <tt>safe refresh</tt> | the actual merge down (from master to branch) that never deletes keys
  # - <tt>safe commit</tt> | now the commit can proceed as the branch is in line with the master
  #
  # == refresh | merge up mechanics
  #
  # The mechanics of a simple in-sync refresh is to
  #
  # - sync the master crypts to exactly mimic the branch crypts
  # - tell master the content id of the book index file
  # - tell master what the current random iv (initialization vector) is
  # - create a new commit ID and set it on both master and branch
  # - set the master's last updated date and time
  #
  class Refresh < Controller


    # The <b>refresh use case</b> commits any changes made to the safe book into
    # master. This is straightforward if the master's state has not been forwarded
    # by a ckeckin from another (shell) branch.
    def execute

      puts ""
      puts " == Birth Day := #{@book.init_time()}\n"
      puts " == Book Name := #{@book.book_name()} [#{@book.book_id}]\n"
      puts " == Book Mark := #{@book.get_open_chapter_name()}/#{@book.get_open_verse_name()}\n" if @book.is_opened?()
      puts ""

      EvolveState.refresh( @book )
      EvolveState.copy_commit_id_to_branch( @book )

      puts "Refresh from master to branch was successful.\n"
      puts ""


    end


  end


end
