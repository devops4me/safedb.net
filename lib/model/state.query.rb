#!/usr/bin/ruby

module SafeDb

  # State queries are related to {StateTransition} but they simple ask for information
  # about the state without changing any state.
  #
  class StateQuery

    # Returns true if valid credentials have been provided earlier on in this
    # session against the book specified in the parameter.
    #
    # Note the "in-use" concept. Even when specified book is not currently
    # in use, true may be returned (as long as a successful login occured).
    #
    # @param book_id [String] book identifier that login request is against
    # @return [Boolean] true if the parameter book is currently logged in
    def self.is_logged_in?( book_id )
      
      branch_id = Identifier.derive_branch_id( Branch.to_token() )
      return false unless File.exists?( FileTree.branch_indices_filepath( branch_id ) )
      branch_keys = DataMap.new( FileTree.branch_indices_filepath( branch_id ) )
      return false unless branch_keys.has_section?( Indices::BRANCH_DATA )
      return false unless branch_keys.has_section?( book_id )

      branch_keys.use( book_id )
      branch_key_ciphertext = branch_keys.get( Indices::CRYPT_CIPHER_TEXT )
      branch_key = KeyDerivation.regenerate_shell_key( Branch.to_token() )

      begin
        branch_key.do_decrypt_key( branch_key_ciphertext )
        return true
      rescue OpenSSL::Cipher::CipherError => e
        log.warn(x) { "A login check against book #{book_id} has failed." }
        log.warn(x) { "Login failure error message is #{e.message}" }
        return false
      end

      return false # technically this line of code is unreachable

    end


    # Have any logins to this safe book occured since the machine was last
    # rebooted? If no, true is returned. If another login has already occurred
    # since the reboot false is returned.
    #
    # This method examines the bootup ID and if one exists and is equivalent
    # to the current one, false is returned. Otherwise true is returned.
    #
    # Set the booup identifier within the parameter key/value map under the
    # globally recognized {Indices::BOOTUP_IDENTIFIER} constant. This method
    # expects the {DataMap} section name to be a significant identifier.
    #
    # @param data_map [DataMap] the data map in which we set the bootup id
    # @return [Boolean] true if this is the first book login since bootup
    def self.is_first_login?( data_map )
      
      puts "Data Map is Below"
      puts data_map.to_s
      return true unless data_map.contains?( Indices::BOOTUP_IDENTIFIER )
      old_bootup_id = data_map.get( Indices::BOOTUP_IDENTIFIER )
      new_bootup_id = MachineId.get_bootup_id()
      puts "Old Bootup ID => #{old_bootup_id}"
      puts "New Bootup ID => #{new_bootup_id}"
      return old_bootup_id != new_bootup_id

    end


  end


end
