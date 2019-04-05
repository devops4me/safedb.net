#!/usr/bin/ruby

module SafeDb

  # The login process recycles the content encryption key by regenerating the human
  # key from the password text and salts and then accessing the old crypt key, generating
  # the new one and deftly unlocking the master database with the old and immediately
  # locking it back up again with the new.
  #
  # The login process also creates a new workspace consisting of
  # - a clone of the master content crypt files
  # - a new set of indices allowing for the acquisition of the new content key via a shell-based session key
  # - a mirrored commit reference that allows commit (save) back to the master if it hasn't moved forward
  # - stating that subsequent commands are for this book and other session books in play are to be set aside
  #
  # The logout process destroys the breadcrumb route back to the re-acquisition of the
  # content encryption key via the shell session key. It also deletes the session crypts.
  #
  # == Login Logout Stack Push Pop
  #
  # The login/logout works like a stack push pop or like a nested structure. A login wrests
  # control away from the currently logged in book whilst a logout cedes control to the
  # book that was last in play.
  #
  # <b>Login Recycles 3 things</b>
  #
  # The three (3) things recycled by this login are
  #
  # - the human key (sourced by putting the secret text through two key derivation functions)
  # - the content crypt key (sourced from a random 48 byte sequence) 
  # - the content ciphertext (sourced by decrypting with the old and re-encrypting with the new)
  #
  # Remember that the content crypt key is itself encrypted by two key entities.
  #
  class LoginOut

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
    #    The secret text is discarded and the <b>derived inter-session key</b> is used
    #    only to encrypt the <em>randomly generated super strong <b>index key</b></em>,
    #    <b>before being itself discarded</b>.
    #
    #    The key ring only stores the salts. This means the secret text based key can
    #    only be regenerated at the next login, which explains the inter-session label.
    #
    def self.do_login( book_keys, secret )

      the_book_id = book_keys.section()

      old_human_key = KdfApi.regenerate_from_salts( secret, book_keys )
      old_crypt_key = old_human_key.do_decrypt_key( book_keys.get( Indices::INTER_SESSION_KEY_CRYPT ) )
      plain_content = Content.unlock_master( old_crypt_key, book_keys )
      new_crypt_key = KeyCycle.recycle( the_book_id, secret, book_keys, plain_content )

      session_id = Identifier.derive_session_id( ShellSession.to_token() )
      clone_book_into_session( the_book_id, session_id, book_keys, new_crypt_key )

    end


    # <b>Logout of the shell key session</b> by making the high entropy content
    # encryption key <b>irretrievable for all intents and purposes</b> to anyone
    # who does not possess the domain secret.
    #
    # The key logout action is deleting the ciphertext originally produced when
    # the intra-sessionary (shell) key encrypted the content encryption key.
    #
    # <b>Why Isn't the Session Token Deleted?</b>
    #
    # The session token is left to <b>die by natural causes</b> so that we don't
    # interfere with other domain interactions that may be in progress within
    # this shell session.
    #
    # @param domain_name [String]
    #    the string reference that points to the application instance that we
    #    are logging out of from the shell on this machine.
    def self.do_logout( domain_name )

# @todo usecase => logout logic that deletes session and allows nested book to bubble up
# @todo usecase => if logging out when book changed (set one of two flags) - ERROR if flags not provided
# @todo usecase => safe logout --commit    OR
# @todo usecase => safe logout --ignore    OR

    end


    # Has the user orchestrating this shell session logged in? Yes or no?
    # If yes then they appear to have supplied the correct secret
    #
    # - in this shell session
    # - on this machine and
    # - for this application instance
    #
    # Use the crumbs found underneath the universal (session) ID within the
    # main breadcrumbs file for this application instance.
    #
    # Note that the system does not rely on this value for its security, it
    # exists only to give a pleasant error message.
    #
    # @return [Boolean]
    #    return true if a marker denoting that this shell session with this
    #    application instance on this machine has logged in. Subverting this
    #    return value only serves to evoke disgraceful degradation.
    def self.is_logged_in?( domain_name )

# @todo usecase => write code saying you are already logged into book (state time).

      return false unless File.exists?( XXXXXXXXXXX )

      crumbs_db = DataMap.new( blah_blah_blah_filepath() )
      crumbs_db.use( XXXXXXXXXXXXX )
      return false unless crumbs_db.contains?( XXXXXXXXXXXXXXX )

      recorded_id = crumbs_db.get( XXXXXXXXXXXXXXXXX )
      return recorded_id.eql?( @uni_id )

    end


    # When we login to a book which may or may not be the first book in the session
    # that we have logged into, we are effectively cloning all its master crypts and
    # some of its keys (indices).
    #
    # To clone a book into a session we
    #
    # - create a session crypts folder and copy all master crypts into it
    # - we create session indices under general and book_id sections
    # - we copy the commit reference and content identifier from the master
    # - lock the content crypt key with the session key and save the ciphertext
    #
    # == commit references
    #
    # We can only commit (save) a session's crypts when the master and session commit
    # references match. The commit process places a new commit reference into both
    # the master and session indices. Like git's push/pull, this prevents a sync when
    # the master has moved forward by one or more commits.
    #
    # @param book_id [String] the book identifier this session is about
    # @param session_id [String] the identifier pertaining to this session
    # @param master_keys [DataMap] keys from the book's master line
    # @param crypt_key [Key] symmetric session content encryption key
    #
    def self.clone_book_into_session( book_id, session_id, master_keys, crypt_key )

      FileUtils.mkdir_p( FileTree.session_crypts_folder( book_id, session_id ) )
      FileUtils.copy_entry( FileTree.master_crypts_folder( book_id ), FileTree.session_crypts_folder( book_id, session_id ) )
      session_keys = create_session_indices( book_id, session_id )

      session_keys.set( Indices::CONTENT_IDENTIFIER, master_keys.get( Indices::CONTENT_IDENTIFIER ) )
      session_keys.set( Indices::CONTENT_RANDOM_IV,  master_keys.get( Indices::CONTENT_RANDOM_IV  ) )
      session_keys.set( Indices::SESSION_COMMIT_ID,  master_keys.get( Indices::MASTER_COMMIT_ID   ) )

      session_key = KeyDerivation.regenerate_shell_key( ShellSession.to_token() )
      key_ciphertext = session_key.do_encrypt_key( crypt_key )
      session_keys.set( Indices::INTRA_SESSION_KEY_CRYPT, key_ciphertext )

    end


    # Create and return the session indices {DataMap} pertaining to both the current
    # book and session whose ids are given in the first and second parameters.
    #
    # @param book_id [String] the book identifier this session is about
    # @param session_id [String] the identifier pertaining to this session
    # @return [DataMap] return the keys pertaining to this session and book
    def self.create_session_indices( book_id, session_id )

      session_exists = File.exists? FileTree.session_indices_filepath( session_id )
      session_keys = DataMap.new( FileTree.session_indices_filepath( session_id ) )
      session_keys.use( Indices::SESSION_DATA )
      session_keys.set( Indices::SESSION_INITIAL_LOGIN_TIME, KeyNow.readable() ) unless session_exists
      session_keys.set( Indices::SESSION_LAST_ACCESSED_TIME, KeyNow.readable() )
      session_keys.set( Indices::CURRENT_SESSION_BOOK_ID, book_id )

      logged_in = session_keys.has_section?( book_id )
      session_keys.use( book_id )
      session_keys.set( Indices::BOOK_SESSION_LOGIN_TIME, KeyNow.readable() ) unless logged_in
      session_keys.set( Indices::BOOK_LAST_ACCESSED_TIME, KeyNow.readable() )

      return session_keys

    end


  end


end
