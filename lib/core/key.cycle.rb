#!/usr/bin/ruby

module SafeDb

  # Use the key applications programming interface to transition the
  # state of three (3) core keys in accordance with the needs of the
  # executing use case.
  #
  # == KeyApi | The 3 Keys
  #
  # The three keys service the needs of a <b>command line application</b>
  # that executes within a <b>shell environment in a unix envirronment</b>
  # or a <b>command prompt in windows</b>.
  #
  # So what are the 3 keys and what is their purpose.
  #
  # - shell key | exists to lock the index key created at login
  # - human key | exists to lock the index key created at login
  # - index key | exists to lock the application's index file
  #
  # So why do two keys (the shell key and human key) exist to lock the
  # same index key?
  #
  # == KeyApi | Why Lock the Index Key Twice?
  #
  # On this login, the <b>previous login's human key is regenerated</b> from
  # the <b>human password and the saved salts</b>. This <em>old human key</em>
  # decrypts and reveals the <b><em>old index key</em></b> which in turn
  # decrypts and reveals the index string.
  #
  # Both the old human key and the old index key are discarded.
  #
  # Then 48 bytes of randomness are sourced to generate the new index key. This
  # key encrypts the now decrypted index string and is thrown away. The password
  # sources a new human key (the salts are saved), and this new key locks the
  # index key's source bytes.
  #
  # The shell key again locks the index key's source bytes. <b><em>Why twice?</em></b>
  #
  # - during subsequent shell command calls the human key is unavailable however
  #   the index key can be accessed via the shell key.
  #
  # - when the shell dies (or logout is issued) the shell key dies. Now the index
  #   key can only be accessed by a login when the password is made available.
  #
  # That is why the index key is locked twice. The shell key opens it mid-branch
  # and the regenerated human key opens it during the login of the next branch.
  #
  # == The LifeCycle of each Key
  #
  # It seems odd that the human key is born during this login then dies
  # at the very next one (as stated below). This is because the human key
  # isn't the password, <b>the human key is sourced from the password</b>.
  #
  # So when are the 3 keys <b>born</b> and when do they <b>cease being</b>.
  #
  # - shell key | is born when the shell is created and dies when the shell dies
  # - human key | is born when the user logs in this time and dies at the next login
  # - index key | the life of the index key exactly mirrors that of the human key
  #
  class KeyCycle


    # During initialization or login we recycle keys produced by key derivation
    # functions (BCrypt. SCrypt and/or PBKDF2) from human sourced secrets.
    #
    # The flow of events of the recycling process is to
    #
    # - generate a random high entropy key for content locking
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
    # @param book_id [String] the identifier of the book whose keys we are cycling
    # @param human_secret [String] this secret is sourced into key derivation functions
    # @param data_map [Hash] book related key/value data that will be populated as appropriate
    # @param content_body [String] this content is encrypted and the ciphertext output stored
    # @return [Key] the generated random high entropy key that the content is locked with
    #
    def self.recycle( book_id, human_secret, data_map, content_body )

      high_entropy_key = Key.from_random
      Content.lock_master( book_id, high_entropy_key, data_map, content_body )
      derived_key = KdfApi.generate_from_password( human_secret, data_map )
      data_map.set( Indices::MASTER_KEY_CRYPT, derived_key.do_encrypt_key( high_entropy_key ) )
      return high_entropy_key

    end


  end


end