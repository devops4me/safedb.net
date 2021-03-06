#!/usr/bin/ruby

module SafeDb

  # Cycle cycles state indices and content crypt files to and from master and branches.
  # The need to cycle content occurs during
  #
  # - <tt>initialization</tt> - a new master state box is created
  # - <tt>login</tt> - branch state is created that mirrors master
  # - <tt>commit</tt> - transfers state from branch to master
  # - <tt>refresh</tt> - transfers state from master to branch
  #
  class EvolveState

    # The login process recycles the content encryption key by regenerating the human
    # key from the password text and salts and then accessing the old crypt key, generating
    # the new one and deftly unlocking the master database with the old and immediately
    # locking it back up again with the new.
    #
    # It also creates a new workspace of crypts and indices that initially mirror the current
    # state of the master book. A login acts like a stack push in that it wrests control from
    # the current book only to cede it back during logout.

    # We recycle the (kdf) derived key every time we are handed the human password
    # (during init and login) but the high entropy machine generated random key is
    # only recycled at a special time.
    #
    # == When is the high entropy key recycled?
    #
    # The high entropy key is recycled only on the first login into a book since the
    # machine reboot. This is because subsequent branch logins that protect the
    # random key will need to check back with the master branch when performing either
    # a diff or refresh operations. Also the commit operation must maintain the
    # same content encryption key for readability by validated agents.
    #
    # @param book_name [String]
    #    the name of the book we are attempting to login to
    #
    # @param book_keys [DataMap]
    #    the {DataMap} contains the salts for key rederivation seeing as we have the
    #    book password and the rederived key will be able to unlock the ciphertext
    #    along with the random initialization vector (iv) also in the key map.
    #
    #    Unlocking the ciphertext reveals the random high entropy key which can be
    #    used for the asymmetric decryption of the content ciphertext which is in a
    #    file marked with the content identifier also within the book keys.
    #
    # @param human_secret [String]
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
    # @return [Boolean]
    #    return false if failure decrypting with human password occurs.
    #    True is returned if the login logic completes naturally.
    def self.login( book_name, book_keys, human_secret )

      the_book_id = book_keys.section()

      old_human_key = KdfApi.regenerate_from_salts( human_secret, book_keys )
      is_correct_password = old_human_key.can_decrypt_key( book_keys.get( Indices::CRYPT_CIPHER_TEXT ) )
      return false unless is_correct_password

      the_crypt_key = old_human_key.do_decrypt_key( book_keys.get( Indices::CRYPT_CIPHER_TEXT ) )
      plain_content = Content.unlock_master( the_crypt_key, book_keys )

      remove_crypt_path = FileTree.master_crypts_filepath( the_book_id, book_keys.get( Indices::CONTENT_IDENTIFIER ) )

      first_login_since_boot = StateInspect.is_first_login?( book_keys )
      the_crypt_key = Key.from_random if first_login_since_boot
      recycle_keys( the_crypt_key, the_book_id, human_secret, book_keys, plain_content )
      set_bootup_id( book_keys ) if first_login_since_boot

      create_crypt_path = FileTree.master_crypts_filepath( the_book_id, book_keys.get( Indices::CONTENT_IDENTIFIER ) )
      branch_id = Identifier.derive_branch_id( Branch.to_token() )
      commit_msg = "safe login to #{the_book_id} at branch #{branch_id} on #{TimeStamp.readable()}."

      # Remove the master chapter crypt file from the local git repository and add
      # the new master chapter crypt to the local git repository.
      gitflow = GitFlow.new( FileTree.master_book_folder( book_name ) )
      gitflow.del_file( remove_crypt_path )
      gitflow.add_file( create_crypt_path )
      gitflow.add_file( FileTree.master_book_indices_filepath(book_name ) )
      gitflow.list(false )
      gitflow.list(true )
      gitflow.commit( commit_msg )

      clone_book_into_branch( the_book_id, branch_id, book_keys, the_crypt_key )

      return true

    end



    # This method creates a new high entropy content encryption key and then forwards
    # it on to behaviour that recycles the (kdf) key from the provided human sourced
    # secret.
    #
    # @param book_id [String] the identifier of the book whose keys we are cycling
    # @param human_secret [String] this secret is sourced into key derivation functions
    # @param data_map [Hash] book related key/value data that will be populated as appropriate
    # @param content_body [String] this content is encrypted and the ciphertext output stored
    # @return [Key] the generated random high entropy key that the content is locked with
    #
    def self.recycle_both_keys( book_id, human_secret, data_map, content_body )
      recycle_keys( Key.from_random(), book_id, human_secret, data_map, content_body )
    end


    # During initialization or login we recycle keys produced by key derivation
    # functions (BCrypt. SCrypt and/or PBKDF2) from human sourced secrets.
    #
    # The flow of events of the recycling process is to
    #
    # - use the random high entropy key given in parameter one
    # - lock the provided content with this high entropy key
    # - save ciphertext in a file named by a random identifier
    # - write this random identifier to the key cache
    # - write the initialization vector to the key cache
    # - use KDFs to derive a key from the human sourced password
    # - save the salts crucial for reproducing this derived key
    # - use the derived key to encrypt the high entropy key
    # - write the resulting ciphertext into the key cache
    # - return the high entropy key that locked the content
    #
    # @param high_entropy_key [Key] the machine generated high entropy content encryption key
    # @param book_id [String] the identifier of the book whose keys we are cycling
    # @param human_secret [String] this secret is sourced into key derivation functions
    # @param data_map [Hash] book related key/value data that will be populated as appropriate
    # @param content_body [String] this content is encrypted and the ciphertext output stored
    def self.recycle_keys( high_entropy_key, book_id, human_secret, data_map, content_body )

      Content.lock_master( book_id, high_entropy_key, data_map, content_body )
      derived_key = KdfApi.generate_from_password( human_secret, data_map )
      data_map.set( Indices::CRYPT_CIPHER_TEXT, derived_key.do_encrypt_key( high_entropy_key ) )

    end


    # In the main, the <tt>commit use case</tt> changes the master so that it mirrors
    # the branch's state. A commit syncs the master's state to mirror the branch.
    #
    # == The Simple Check In
    #
    # The simplest case is when no other branch has issued a commit since this branch
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
    # - <tt>or a branch commit</tt>
    #
    # The commit ID is copied from master to branch during
    #
    # - <tt>either subsequent logins</tt>
    # - <tt>or a branch refresh</tt>
    #
    # @param book [Book] the book whose data we want to commit
    def self.commit( book )

# @todo => If mismatch in commit IDs then print message instructing to first do safe refresh

      FileUtils.remove_entry( FileTree.master_crypts_folder( book.book_name() ) )
      FileUtils.mkdir_p( FileTree.master_crypts_folder( book.book_name() ) )
      FileUtils.copy_entry( FileTree.branch_crypts_folder( book.book_name(), book.branch_id() ), FileTree.master_crypts_folder( book.book_name() ) )

      master_keys = DataMap.new( FileTree.master_book_indices_filepath(book.book_name() ) )
      master_keys.use( book.book_name() )
      branch_keys = DataMap.new( FileTree.branch_indices_filepath( book.branch_id() ) )
      branch_keys.use( book.book_name() )

      commit_id = Identifier.get_random_identifier( 16 )
      branch_keys.set( Indices::COMMIT_IDENTIFIER, commit_id )
      master_keys.set( Indices::COMMIT_IDENTIFIER, commit_id )

      master_keys.set( Indices::CONTENT_IDENTIFIER, branch_keys.get( Indices::CONTENT_IDENTIFIER ) )
      master_keys.set( Indices::CONTENT_RANDOM_IV,  branch_keys.get( Indices::CONTENT_RANDOM_IV  ) )

      commit_msg = "safe commit for #{book.book_name()} in branch #{book.branch_id()} on #{TimeStamp.readable()}."

      gitflow = GitFlow.new( FileTree.master_book_folder( book.book_name ) )
      gitflow.stage()
      gitflow.list( false )
      gitflow.list( true )
      gitflow.commit( commit_msg )

    end



    # A refresh merges down the master's data into the data of this working branch.
    # The <tt>commit ID</tt> of the working branch after the refresh is made to be
    # equivalent with that of the master. This act signifies that a commit is now 
    # allowed (as long as another branch doesn't commit in the meantime).
    #
    # @param book [Book] the book whose master data will be merged down into the branch.
    def self.refresh( book )

      master_data = book.to_master_data()
      branch_data = book.to_branch_data()

      merged_verse_count = 0
      master_data.each_pair do | chapter_name, chapter_data |
        book.import_chapter( chapter_name, chapter_data )
        merged_verse_count += chapter_data.length()
      end

      book.write()

      puts ""
      puts "#{master_data.length()} chapters and #{merged_verse_count} verses from master were merged in.\n"
      puts ""

    end


    # Copy the master commit identifier to the branch. This signifies that the branch
    # is aligned (and ready) to commit its changes into the master.
    # @param book [Book] the book whose commit IDs will be manipulated
    def self.copy_commit_id_to_branch( book )

      master_keys = DataMap.new( FileTree.master_book_indices_filepath( book.book_name() ) )
      master_keys.use( book.book_name() )
      branch_keys = DataMap.new( FileTree.branch_indices_filepath( book.branch_id() ) )
      branch_keys.use( book.book_name() )

      master_commit_id = master_keys.get( Indices::COMMIT_IDENTIFIER )
      branch_keys.set( Indices::COMMIT_IDENTIFIER, master_commit_id )

    end


    # Set the booup identifier within the parameter key/value map under the
    # globally recognized {Indices::BOOTUP_IDENTIFIER} constant. This method
    # expects the {DataMap} section name to be a significant identifier.
    #
    # @param data_map [DataMap] the data map in which we set the bootup id
    def self.set_bootup_id( data_map )

      has_bootup_id = data_map.contains?( Indices::BOOTUP_IDENTIFIER )
      old_bootup_id = data_map.get( Indices::BOOTUP_IDENTIFIER ) if has_bootup_id
      log.info(x) { "overriding bootup id [#{old_bootup_id}] in section [#{data_map.section()}]." } if has_bootup_id

      new_bootup_id = MachineId.get_bootup_id()
      data_map.set( Indices::BOOTUP_IDENTIFIER, new_bootup_id )
      log.info(x) { "setting bootup id in section [#{data_map.section()}] to [#{new_bootup_id}]." }
      MachineId.log_reboot_times()

    end


    # Create the book within the master indices file and set its book identifier
    # along with the initialize time and a fresh commit identifier.
    #
    # @param book_name [String] the name of the book to create
    def self.create_book( book_name )
      FileUtils.mkdir_p( FileTree.master_crypts_folder( book_name ) )

      keypairs = DataMap.new( FileTree.master_book_indices_filepath(book_name ) )
      keypairs.use( book_name )
      keypairs.set( Indices::SAFE_BOOK_INITIALIZE_TIME, TimeStamp.readable() )
      keypairs.set( Indices::COMMIT_IDENTIFIER, Identifier.get_random_identifier( 16 ) )
    end


    # Switch the current branch (if necessary) to using the book whose ID
    # is specified in the parameter. Only call method if we are definitely
    # in a logged in state.
    #
    # @param book_name [String] book name that login request is against
    def self.use_book( book_name )
      branch_id = Identifier.derive_branch_id( Branch.to_token() )
      branch_keys = DataMap.new( FileTree.branch_indices_filepath( branch_id ) )
      branch_keys.use( Indices::BRANCH_DATA )
      current_book_id = branch_keys.get( Indices::CURRENT_BRANCH_BOOK_ID )
      log.info(x) { "Current book is #{current_book_id} and the instruction is to use #{book_name}" }
      branch_keys.set( Indices::CURRENT_BRANCH_BOOK_ID, book_name )
    end


    # When we login to a book which may or may not be the first book in the branch
    # that we have logged into, we are effectively cloning all its master crypts and
    # some of its keys (indices).
    #
    # To clone a book into a branch we
    #
    # - create a branch crypts folder and copy all master crypts into it
    # - we create branch indices under general and book name sections
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
    # @param book_name [String] the book identifier this branch is about
    # @param branch_id [String] the identifier pertaining to this branch
    # @param master_keys [DataMap] keys from the book's master line
    # @param crypt_key [Key] symmetric branch content encryption key
    #
    def self.clone_book_into_branch( book_name, branch_id, master_keys, crypt_key )

      FileUtils.mkdir_p( FileTree.branch_crypts_folder( book_name, branch_id ) )
      FileUtils.copy_entry( FileTree.master_crypts_folder( book_name ), FileTree.branch_crypts_folder( book_name, branch_id ) )
      branch_keys = create_branch_indices( book_name, branch_id )

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
    # @param book_name [String] the book identifier this branch is about
    # @param branch_id [String] the identifier pertaining to this branch
    # @return [DataMap] return the keys pertaining to this branch and book
    def self.create_branch_indices( book_name, branch_id )

      branch_exists = File.exists? FileTree.branch_indices_filepath( branch_id )
      branch_keys = DataMap.new( FileTree.branch_indices_filepath( branch_id ) )
      branch_keys.use( Indices::BRANCH_DATA )
      branch_keys.set( Indices::BRANCH_INITIAL_LOGIN_TIME, TimeStamp.readable() ) unless branch_exists
      branch_keys.set( Indices::BRANCH_LAST_ACCESSED_TIME, TimeStamp.readable() )
      branch_keys.set( Indices::CURRENT_BRANCH_BOOK_ID, book_name )

      logged_in = branch_keys.has_section?( book_name )
      branch_keys.use( book_name )
      branch_keys.set( Indices::BOOK_BRANCH_LOGIN_TIME, TimeStamp.readable() ) unless logged_in
      branch_keys.set( Indices::BOOK_LAST_ACCESSED_TIME, TimeStamp.readable() )

      return branch_keys

    end


  end


end
