#!/usr/bin/ruby
# coding: utf-8

module SafeDb

  # The command line interface has a high entropy randomly generated
  # key whose purpose is to <b>lock the application's data key</b> for
  # the duration of the branch which is between a login and a logout.
  # 
  # These keys are unique to only one shell on one workstation
  # and they live lives that are no longer (and mostly shorter) than
  # the life of the parent shell.
  #
  # == The 4 CLI Shell Entities
  #
  # The four (4) important entities within the shell are
  #
  # - an obfuscator key for locking the shell key during a branch
  # - a high entropy randomly generated shell key for locking the app data key
  # - one environment variable whose value embodies three (3) data segments
  # - a branch id derived by pushing the env var through a one-way function
  class KeyDerivation


    # The number of Radix64 characters that make up a valid BCrypt salt.
    # To create a BCrypt salt use 
    BCRYPT_SALT_LENGTH = 22


    # There are two digits representing the BCrypt iteration count.
    # The minimum is 10 and the maximum is 16.
    BCRYPT_ITER_COUNT_SIZE = 2


    # The shell token comprises of 3 segments with fixed lengths.
    # This triply segmented text token that can be used to decrypt
    # and deliver the shell key.
    SHELL_TOKEN_SIZE = 128 + 22 + BCRYPT_ITER_COUNT_SIZE


    # Given a 152 character shell token, what is the index that pinpoints
    # the beginning of the 22 character BCrypt salt? The answer is given
    # by this BCRYPT_SALT_START_INDEX constant.
    BCRYPT_SALT_START_INDEX = SHELL_TOKEN_SIZE - BCRYPT_SALT_LENGTH - BCRYPT_ITER_COUNT_SIZE


    # What index pinpoints the end of the BCrypt salt itself.
    # This is easy as the final 2 characters are the iteration count
    # so the end index is the length subtract 1 subtract 2.
    BCRYPT_SALT_END_INDEX = SHELL_TOKEN_SIZE - 1


    # Initialize the branch by generating a random high entropy shell token
    # and then generate an obfuscator key which we use to lock the shell
    # key and return a triply segmented text token that can be used to decrypt
    # and deliver the shell key as long as the same shell on the same machine
    # is employed to make the call.
    #
    # <b>The 3 Shell Token Segments</b>
    #
    # The shell token is divided up into 3 segments with a total of 150
    #  characters.
    #
    #   | -------- | ------------ | ------------------------------------- |
    #   | Segment  | Length       | Purpose                               |
    #   | -------- | ------------ | ------------------------------------- |
    #   |    1     | 16 bytes     | AES Encrypt Initialization Vector(IV) |
    #   |    2     | 80 bytes     | Cipher text from Random Key AES crypt |
    #   |    3     | 22 chars     | Salt for obfuscator key derivation    |
    #   | -------- | ------------ | ------------------------------------- |
    #   |  Total   | 150 chars    | Shell Token in Environment Variable |
    #   | -------- | ------------ | ------------------------------------- |
    #
    # Why is the <b>16 byte salt and the 80 byte BCrypt ciphertext</b> represented
    # by <b>128 base64 characters</b>?
    #
    #    16 bytes + 80 bytes = 96 bytes
    #    96 bytes x 8 bits   = 768 bits
    #    768 bits / 6 bits   = 128 base64 characters
    #
    # @return [String]
    #    return a triply segmented text token that can be used to decrypt
    #    and redeliver the high entropy branch shell key on the same machine
    #    and within the same shell on the same machine.
    def self.generate_shell_key_and_token

      bcrypt_salt_key = KdfBCrypt.generate_bcrypt_salt
      obfuscator_key = derive_branch_crypt_key( bcrypt_salt_key )
      random_key_ciphertext = obfuscator_key.do_encrypt_key( Key.from_random() )
      shell_token = random_key_ciphertext + bcrypt_salt_key.reverse
      assert_shell_token_size( shell_token )

      return shell_token

    end


    # Regenerate the random shell key that was instantiated and locked
    # during the {instantiate_shell_key_and_generate_token} method.
    #
    # To successfully reacquire the randomly generated (and then locked)
    # shell key we must be provided with five (5) data points, four (4)
    # of which are embalmed within the 150 character shell token
    # parameter.
    #
    # <b>What we need to Regenerate the Shell Key</b>
    #
    # Regenerating the shell key is done in two steps when given the
    # four (4) <b>shell token segments</b> described below, and the
    # shell identity key described in the {SafeDb::Identifier} class.
    #
    # The shell token is divided up into 4 segments with a total of 152
    #  characters.
    #
    #   | -------- | ------------ | ------------------------------------- |
    #   | Segment  | Length       | Purpose                               |
    #   | -------- | ------------ | ------------------------------------- |
    #   |    1     | 16 bytes     | AES Encrypt Initialization Vector(IV) |
    #   |    2     | 80 bytes     | Cipher text from Random Key AES crypt |
    #   |    3     | 22 chars     | Salt 4 shell identity key derivation  |
    #   |    4     |  2 chars     | BCrypt iteration parameter (10 to 16) |
    #   | -------- | ------------ | ------------------------------------- |
    #   |  Total   | 152 chars    | Shell Token in Environment Variable |
    #   | -------- | ------------ | ------------------------------------- |
    #
    # @param shell_token [String]
    #    a triply segmented (and one liner) text token instantiated by
    #    {self.instantiate_shell_key_and_generate_token} and provided
    #    here ad verbatim.
    #
    # @return [SafeDb::Key]
    #    an extremely high entropy 256 bit key derived (digested) from 48
    #    random bytes at the beginning of the shell (cli) branch.
    def self.regenerate_shell_key( shell_token )

      assert_shell_token_size( shell_token )
      bcrypt_salt = shell_token[ BCRYPT_SALT_START_INDEX .. BCRYPT_SALT_END_INDEX ].reverse
      assert_bcrypt_salt_size( bcrypt_salt )

      key_ciphertext = shell_token[ 0 .. ( BCRYPT_SALT_START_INDEX - 1 ) ]
      obfuscator_key = derive_branch_crypt_key( bcrypt_salt )
      regenerated_key = obfuscator_key.do_decrypt_key( key_ciphertext )

      return regenerated_key

    end


    # Derive a <b>short term (branch scoped) encryption key</b> from the
    # surrounding shell and workstation (machine) environment with an
    # important same/different guarantee.
    #
    # The <b>same / different guarantee promises</b> us that the derived
    # key will be
    #
    # - <b>the same</b> whenever called from within this executing shell
    # - <b>different</b> when the shell and/or workstation are different
    #
    # This method uses a one-way function to return a combinatorial digested
    # branch identification string using a number of distinct parameters that
    # deliver the important behaviours of changing in certain circumstances
    # and remaining unchanged in others.
    #
    # <b>Change | When Should the key Change?</b>
    #
    # What is really important is that the <b>key changes when</b>
    #
    # - the <b>command shell</b> changes
    # - the workstation <b>shell user is switched</b>
    # - the host machine <b>workstation</b> is changed
    # - the user <b>SSH's</b> into another shell
    #
    # A distinct workstation is identified by the first MAC address and the
    # hostname of the machine.
    #
    # <b>Unchanged | When Should the Key Remain Unchanged?</b>
    #
    # Remaining <b>unchanged</b> in certain scenarios is a feature that is
    # just as important as changing in others. The key must remain
    # <b>unchanged</b> when
    #
    # - the <b>user returns to a command shell</b>
    # - the user exits their <b>remote SSH branch</b>
    # - <b>sudo is used</b> to execute the commands
    # - the user comes back to their <b>workstation</b>
    # - the clock ticks into another day, month, year ...
    #
    # @param bcrypt_salt_key [SafeDb::Key]
    #
    #    Either use BCrypt to generate the salt or retrieve and post in a
    #    previously generated salt which must hold 22 printable characters.
    #
    # @return [SafeDb::Key]
    #    a digested key suitable for short term (branch scoped) use with the
    #    guarantee that the same key will be returned whenever called from within
    #    the same executing shell environment and a different key when not.
    def self.derive_branch_crypt_key bcrypt_salt_key

      shell_id_text = MachineId.derive_shell_identifier()
      truncate_text = shell_id_text.length > KdfBCrypt::BCRYPT_MAX_IN_TEXT_LENGTH
      shell_id_trim = shell_id_text unless truncate_text
      shell_id_trim = shell_id_text[ 0 .. ( KdfBCrypt::BCRYPT_MAX_IN_TEXT_LENGTH - 1 ) ] if truncate_text

      return KdfBCrypt.generate_key( shell_id_trim, bcrypt_salt_key )

    end


    private


    # 000000000000000000000000000000000000000000000000000000000000000
    # How to determine the caller.
    # Better strategy would be just to print the stack trace
    # That gives you much more bang for the one line buck.
    # 000000000000000000000000000000000000000000000000000000000000000
    # calling_module = File.basename caller_locations(1,1).first.absolute_path, ".rb"
    # calling_method = caller_locations(1,1).first.base_label
    # calling_lineno = caller_locations(1,1).first.lineno
    # caller_details = "#{calling_module} | #{calling_method} | (line #{calling_lineno})"
    # log.info(x) { "### Caller Details =>> =>> #{caller_details}" }
    # 000000000000000000000000000000000000000000000000000000000000000


    def self.assert_shell_token_size shell_token
      err_msg = "shell token has #{shell_token.length} and not #{SHELL_TOKEN_SIZE} chars."
      raise RuntimeError, err_msg unless shell_token.length == SHELL_TOKEN_SIZE
    end


    def self.assert_bcrypt_salt_size bcrypt_salt
      amalgam_length = BCRYPT_SALT_LENGTH + BCRYPT_ITER_COUNT_SIZE
      err_msg = "Expected BCrypt salt length of #{amalgam_length} not #{bcrypt_salt.length}."
      raise RuntimeError, err_msg unless bcrypt_salt.length == amalgam_length
    end


  end


end
