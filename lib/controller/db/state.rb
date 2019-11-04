#!/usr/bin/ruby
	
module SafeDb

  # Querying the state of the safe on the current machine is what this command
  # facilitates.
  #
  # == Strategy re Safe Events and Commits
  #
  # - 1. changes to the safe back-end repository should occur only when a book login occurs
  #      for the first time since the machine booted up (already implemented) OR when a book
  #      is created, destroyed or changes after edits are committed. Also after a password
  #      reset "safe password" the indices will be changed and committed.
  #      Things like last accessed time must come out of the master indices file.
  #
  # - 2. 7 key events must be recorded at the JSON path safedb-event-tracking/safedb-events-<<bootup-id>>.json
  #      (above the repository) and these events should be presented in a table in
  #      response to the **`safe state`** command.
  #
  # - 3. the 7 events are book create, book destroy, edit, login, logout, commit, refresh
  #      and they must be stored at the bootup ID referenced path and in conjunction with
  #      the branch ID, book name, book ID and the time the event occurred.
  #
  # == Touched Use Cases
  #
  # This event tracking strategy requires changes in roughly 10 use cases.
  #
  # 1. safe prune - as well as pruning branches with unrecognized bootup IDs we also prune old events files
  # 2. safe state - prints the table of branch, book name, book ID, last state event and the event time
  # 3. safe state - a column titled S has an asterix (*) if edits occur without being followed by a commit or logout
  # 4. safe state - the branch column states "this one" if branch ID matches current branch ID
  # 5. safe state - the table is ordered by the time the branch/books are written in SO THAT the rows do not jump about
  # 6. safe logout - trashes branches and marks the event (branch/book) row so that it is displayed by safe state
  # 6. safe login - changes to trashes branches and marks the event (branch/book) row so that it is displayed by safe state
  # 7. safe destroy <<book>>: - only enact this if the book is not logged in (since boot time) or has been logged out
  # 8. safe destroy <<book>>: - trash branches, master indices and crypts and referencing rows in the event tracker file
  # 9. safe rename <<book>>: - only change section header in INI indices to rename the book
  # 10. safe password - Only allow when no other branch is logged in (its fine if they subsequently logged out)
  #
  #
  # == Limit Occurrences of Book ID
  #
  # Do not write book ID everywhere because renaming and destroying books change will cascade.
  # Book IDs should not be used to name directories or files or crypt headers - (use a reference instead)
  #
  #
  #
  #
  class State < Controller

    def execute()


      return


    end


  end


end
