#!/usr/bin/ruby

module SafeDb

  # Cycle cycles state indices and content crypt files to and from master and branches.
  # The need to cycle content occurs during
  #
  # - <tt>initialization</tt> - a new master state box is created
  # - <tt>login</tt> - branch state is created that mirrors master
  # - <tt>checkin</tt> - transfers state from branch to master
  # - <tt>checkout</tt> - transfers state from master to branch
  #
  class Transition

    # The login process recycles the content encryption key by regenerating the human
    # key from the password text and salts and then accessing the old crypt key, generating
    # the new one and deftly unlocking the master database with the old and immediately
    # locking it back up again with the new.
    #
    # It also creates a new workspace of crypts and indices that initially mirror the current
    # state of the master book. A login acts like a stack push in that it wrests control from
    # the current book only to cede it back during logout.

    # @param book_keys [DataMap]
    #    the {DataMap} contains the salts for key rederivation seeing as we have the
    #    book password and the rederived key will be able to unlock the ciphertext
    #    along with the random initialization vector (iv) also in the key map.
    #
    #    Unlocking the ciphertext reveals the random high entropy key which can be
    #    used for the asymmetric decryption of the content ciphertext which is in a
    #    file marked with the content identifier also within the book keys.
    #
    # @param secret [String]
    #    the secret text that can potentially be cryptographically weak (low entropy).
    #    This text is severely strengthened and morphed into a key using multiple key
    #    derivation functions like <b>PBKDF2, BCrypt</b> and <b>SCrypt</b>.
    #
    #    The secret text is discarded and the <b>derived inter-branch key</b> is used
    #    only to encrypt the <em>randomly generated super strong <b>index key</b></em>,
    #    <b>before being itself discarded</b>.
    #
    #    The key ring only stores the salts. This means the secret text based key can
    #    only be regenerated at the next login, which explains the inter-branch label.
    #
    def self.login( book_keys, secret )

## ===> @todo if the bootup ID differs from the master - we recycle the strong content encryption key

## ===> @todo if the bootup ID differs from the master - we create a new commit ID for master and branch

      the_book_id = book_keys.section()

      old_human_key = KdfApi.regenerate_from_salts( secret, book_keys )
      old_crypt_key = old_human_key.do_decrypt_key( book_keys.get( Indices::CRYPT_CIPHER_TEXT ) )
      plain_content = Content.unlock_master( old_crypt_key, book_keys )

      new_crypt_key = KeyCycle.recycle( the_book_id, secret, book_keys, plain_content )
      branch_id = Identifier.derive_branch_id( Branch.to_token() )
      clone_book_into_branch( the_book_id, branch_id, book_keys, new_crypt_key )

    end


    # In the main, the <tt>checkin use case</tt> changes the master so that it mirrors
    # the branch's state. A check-in syncs the master's state to mirror the branch.
    #
    # == The Simple Check In
    #
    # The simplest case is when no other branch has issued a check-in since this branch
    #
    # - <tt>logged in</tt>
    # - <tt>checked in</tt> or
    # - <tt>checked out</tt>
    #
    # In this case the main events are to
    #
    # - make the master crypts mirror the branch crypts
    # - update the master content ID to mirror the branch
    # - give a new commit ID to both master and branch
    #
    # == The Commit ID Lifecycle
    #
    # A new commit ID is only created during
    #
    # - <tt>either the first login</tt> since the machine booted up
    # - <tt>or a branch checkin</tt>
    #
    # The commit ID is copied from master to branch during
    #
    # - <tt>either subsequent logins</tt>
    # - <tt>or a branch checkout</tt>
    #
    def self.checkin( book )

# @todo => If mismatch in commit IDs then print message instructing to first do safe checkout

      FileUtils.remove_entry( FileTree.master_crypts_folder( book.book_id() ) )
      FileUtils.mkdir_p( FileTree.master_crypts_folder( book.book_id() ) )
      FileUtils.copy_entry( FileTree.branch_crypts_folder( book.book_id(), book.branch_id() ), FileTree.master_crypts_folder( book.book_id() ) )

      master_keys = DataMap.new( Indices::MASTER_INDICES_FILEPATH )
      master_keys.use( book.book_id() )
      branch_keys = DataMap.new( FileTree.branch_indices_filepath( book.branch_id() ) )
      branch_keys.use( book.book_id() )

      checkin_commit_id = Identifier.get_random_identifier( 16 )
      branch_keys.set( Indices::COMMIT_IDENTIFIER, checkin_commit_id )
      master_keys.set( Indices::COMMIT_IDENTIFIER, checkin_commit_id )

      master_keys.set( Indices::CONTENT_IDENTIFIER, branch_keys.get( Indices::CONTENT_IDENTIFIER ) )
      master_keys.set( Indices::CONTENT_RANDOM_IV,  branch_keys.get( Indices::CONTENT_RANDOM_IV  ) )

    end



    # <b>Logout of the shell key branch</b> by making the high entropy content
    # encryption key <b>irretrievable for all intents and purposes</b> to anyone
    # who does not possess the domain secret.
    #
    # The key logout action is deleting the ciphertext originally produced when
    # the intra branch (shell) key encrypted the content encryption key.
    #
    # <b>Why Isn't the Shell Token Deleted?</b>
    #
    # The shell token is left to <b>die by natural causes</b> so that we don't
    # interfere with other domain interactions that may be in progress within
    # this shell.
    #
    # @param domain_name [String]
    #    the string reference that points to the application instance that we
    #    are logging out of from the shell on this machine.
    def self.do_logout( domain_name )

# @todo => logout logic that deletes branch and allows nested book to bubble up
# @todo => if logging out when book changed (set one of two flags) - ERROR if flags not provided
# @todo => safe logout --commit    OR
# @todo => safe logout --ignore    OR

    end


    # If the branch indices file exists it means we have logged into
    # at least one book - furthermore if a section headed up with our
    # book id (derived from the book_name CLI parameter) exists then
    # we have definitely logged into this book.
    #
    # Remember that many books can be in-play in the same shell so
    # it is important to check the "currently in use book id" and then
    # update the value if necessary on receipt of either the login
    # or <tt>use</tt> commands.
    #
    def self.is_logged_in?()

      branch_id = Identifier.derive_branch_id( Branch.to_token() )
      return false unless File.exists? FileTree.branch_indices_filepath( branch_id )
      branch_keys = DataMap.new( FileTree.branch_indices_filepath( branch_id ) )
      return branch_keys.has_section?( book_id )

    end


    # When we login to a book which may or may not be the first book in the branch
    # that we have logged into, we are effectively cloning all its master crypts and
    # some of its keys (indices).
    #
    # To clone a book into a branch we
    #
    # - create a branch crypts folder and copy all master crypts into it
    # - we create branch indices under general and book_id sections
    # - we copy the commit reference and content identifier from the master
    # - lock the content crypt key with the branch key and save the ciphertext
    #
    # == commit references
    #
    # We can only commit (save) a branch's crypts when the master and branch commit
    # references match. The commit process places a new commit reference into both
    # the master and branch indices. Like git's push/pull, this prevents a sync when
    # the master has moved forward by one or more commits.
    #
    # @param book_id [String] the book identifier this branch is about
    # @param branch_id [String] the identifier pertaining to this branch
    # @param master_keys [DataMap] keys from the book's master line
    # @param crypt_key [Key] symmetric branch content encryption key
    #
    def self.clone_book_into_branch( book_id, branch_id, master_keys, crypt_key )

      FileUtils.mkdir_p( FileTree.branch_crypts_folder( book_id, branch_id ) )
      FileUtils.copy_entry( FileTree.master_crypts_folder( book_id ), FileTree.branch_crypts_folder( book_id, branch_id ) )
      branch_keys = create_branch_indices( book_id, branch_id )

      branch_keys.set( Indices::CONTENT_IDENTIFIER, master_keys.get( Indices::CONTENT_IDENTIFIER ) )
      branch_keys.set( Indices::CONTENT_RANDOM_IV,  master_keys.get( Indices::CONTENT_RANDOM_IV  ) )
      branch_keys.set( Indices::COMMIT_IDENTIFIER,   master_keys.get( Indices::COMMIT_IDENTIFIER   ) )

      branch_key = KeyDerivation.regenerate_shell_key( Branch.to_token() )
      key_ciphertext = branch_key.do_encrypt_key( crypt_key )
      branch_keys.set( Indices::CRYPT_CIPHER_TEXT, key_ciphertext )

    end


    # Create and return the branch indices {DataMap} pertaining to both the current
    # book and branch whose ids are given in the first and second parameters.
    #
    # @param book_id [String] the book identifier this branch is about
    # @param branch_id [String] the identifier pertaining to this branch
    # @return [DataMap] return the keys pertaining to this branch and book
    def self.create_branch_indices( book_id, branch_id )

      branch_exists = File.exists? FileTree.branch_indices_filepath( branch_id )
      branch_keys = DataMap.new( FileTree.branch_indices_filepath( branch_id ) )
      branch_keys.use( Indices::BRANCH_DATA )
      branch_keys.set( Indices::BRANCH_INITIAL_LOGIN_TIME, KeyNow.readable() ) unless branch_exists
      branch_keys.set( Indices::BRANCH_LAST_ACCESSED_TIME, KeyNow.readable() )
      branch_keys.set( Indices::CURRENT_BRANCH_BOOK_ID, book_id )

      logged_in = branch_keys.has_section?( book_id )
      branch_keys.use( book_id )
      branch_keys.set( Indices::BOOK_BRANCH_LOGIN_TIME, KeyNow.readable() ) unless logged_in
      branch_keys.set( Indices::BOOK_LAST_ACCESSED_TIME, KeyNow.readable() )

      return branch_keys

    end


  end


end
