#!/usr/bin/ruby
# coding: utf-8

module SafeDb

  # The SafeDb underlying security strategy is to lock a master index file
  # with a <b>symmetric encryption key</b> that is based on two randomly generated
  # and amalgamated <b>55 and 45 character keys</b> and then to lock that key
  # <b>(and only that key)</b> with a 256 bit symmetric encryption key derived from
  # a human password and generated by at least two cryptographic workhorses known
  # as <b>key derivation functions</b>.
  #
  # Random powerful keys are derived are seeded with 55 random bytes and
  # then fed through the master key generator and its two key derivation
  # functions (BCrypt and PBKDF2).
  #
  # == What Does the Master Encryption Key Generator Do?
  #
  # This class sits at the core of implementing that strategy and works to produce
  # 256 bit encryption key derived from a human password which is then minced by
  # two best of breed key derivation functions (BCrypt and PBKDF2).
  #
  # BCrypt (Blowfish) and PBKDF2 are the leading <b>key derivation functions</b>
  # whose modus operandi is to convert <b>low entropy</b> human generated passwords
  # into a high entropy key that is computationally infeasible to acquire via brute
  # force.
  #
  # == How to Create the Encryption Key
  #
  # To create a high entropy encryption key this method takes the first
  # 168 bits from the 186 bit BCrypt key and the first 96 bits from the
  # 132 bit PBKDF2 key and amalgamates them to produce a 264 bit key.
  #
  # The 264 bit key is then digested to produce a 256bit encryption key.
  class KdfApi


    # BCrypt (Blowfish) and PBKDF2 are the leading <b>key derivation functions</b>
    # whose modus operandi is to convert <b>low entropy</b> human generated passwords
    # into a high entropy key that is computationally infeasible to acquire via brute
    # force.
    BCRYPT_SALT_KEY_NAME = "bcrypt.salt"

 
    # BCrypt (Blowfish) and PBKDF2 are the leading <b>key derivation functions</b>
    # whose modus operandi is to convert <b>low entropy</b> human generated passwords
    # into a high entropy key that is computationally infeasible to acquire via brute
    # force.
    PBKDF2_SALT_KEY_NAME = "pbkdf2.salt"


    # To create a high entropy encryption key we use the full 180 bits
    # from the returned 180 bit BCrypt key.
    #
    # When amalgamated with the <b>332 bits from the PBKDF2 Key</b> we
    # achieve a powerful <b>union key length</b> of 512 bits.
    BCRYPT_KEY_CONTRIBUTION_SIZE = 180


    # The first 332 bits are used from the 384 bit key returned by the
    # PBKDF2 algorithm.
    #
    # When amalgamated with the <b>180 bits from the BCrypt Key</b> we
    # achieve a powerful <b>union key length</b> of 512 bits.
    PBKDF2_KEY_CONTRIBUTION_SIZE = 332


    # To create a high entropy encryption key we use the full 180 bits
    # from the returned 180 bit BCrypt key and the first 332 bits from
    # the 384 bit PBKDF2 key.
    #
    # On amalgamation, the outcome is a quality <b>union key length</b>
    # of <b>512 bits</b>.
    AMALGAM_KEY_RAW_BIT_SIZE = BCRYPT_KEY_CONTRIBUTION_SIZE + PBKDF2_KEY_CONTRIBUTION_SIZE


    # This method generates a 256 bit symmetric encryption key by passing a
    # textual human sourced secret into two <b>key derivation functions</b>,
    # namely <b>BCrypt and PBKDF2</b>. BCrypt, PBKDF2 and SCrypt are today's
    # <b>in form best of breed</b> cryptographic workhorses for producing a
    # high entropy key from possibly weak human sourced secret text.
    #
    # <b>Example | Derive Key from Password</b>
    #
    #    data_store = DataMap.new( "/path/to/kdf-salt-data.ini" )
    #    data_store.use( "peter-pan" )
    #    human_key = KdfApi.generate_from_password( "my_s3cr3t", data_store )
    #
    #    strong_key = Key.from_random()
    #    human_key.encrypt_key( strong_key, data_store )
    #
    #    strong_key.encrypt_file "/path/to/file-to-encrypt.pdf"
    #    strong_key.encrypt_text "I am the text to encrypt."
    #
    # ---
    #
    # <b>Do not use the key derived from a human secret</b> to encrypt anything
    # other than a <b>high entropy key</b> randomly sourced from 48 bytes.
    # 
    # Every time the user logs in, generate (recycle), another human key and
    # another strong key and discard the previously outputted cipher texts.
    #
    # == BCrypt and the PBKDF2 Cryptographic Algorithms
    #
    # BCrypt (Blowfish) and PBKDF2 are the leading <b>key derivation functions</b>
    # that exists to convert <b>low entropy</b> human generated passwords into a high
    # entropy key that is computationally infeasible to acquire through brute force.
    #
    # On amalgamation, the outcome is a quality <b>union key length</b>
    # of <b>512 bits</b>.
    #
    # == Creating a High Entropy Encryption Key
    #
    # To create a high entropy encryption key this method takes the first
    # 168 bits from the 186 bit BCrypt and the first 96 bits from the 132
    # bit PBKDF2 key and amalgamates them to produce a 264 bit key.
    #
    # Note that all four of the above numbers are divisable by six (6), for
    # representation with a 64 character set, and eight (8), for transport
    # via the byte (8 bit) protocols.
    #
    # <b>Size of BCrypt and PBKDF2 Derived Keys</b>
    #
    #   + --------- - --------- +
    #   + --------- | --------- +
    #   | Algorithm | Bit Count |
    #   ----------- | --------- |
    #   | BCrypt    |  180 Bits |
    #   | Pbkdf2    |  332 Bits |
    #   ----------- | --------- |
    #   | Total     |  512 Bits |
    #   + --------- | --------- +
    #   + --------- - --------- +
    #
    # <b>256 Bit Encryption Key | Remove 8 Bits</b>
    #
    # The manufactured encryption key, an amalgam of the above now has
    # 264 bits carried by 44 Base64 characters.
    #
    # Just before it is used to encrypt vital keys, eight (8) bits are
    # removed from the end of the key. The key is then converted into a
    # powerful 32 byte (256 bit) encryption agent and is hashed by the
    # SHA256 digest and delivered.
    #
    # @param human_secret [String]
    #    a robust human generated password with as much entropy as can
    #    be mustered. Remember that 40 characters spread randomly over
    #    the key space of about 90 characters and not relating to any
    #    dictionary word or name is the way to generate a powerful key
    #    that has embedded a near 100% entropy rating.
    #
    # @param data_map [DataMap]
    #    The DataMap storage service must have been initialized and a
    #    section specified using {DataMap.use} thus allowing this method
    #    to <b>write key-value pairs</b> representing the BCrypt and
    #    PBKDF2 salts through the {DataMap.set} behaviour.
    #
    # @return [Key]
    #    the 256 bit symmetric encryption key derived from a human password
    #    and passed through two cryptographic workhorses.
    def self.generate_from_password human_secret, data_map

      bcrypt_salt = KdfBCrypt.generate_bcrypt_salt
      pbkdf2_salt = KeyPbkdf2.generate_pbkdf2_salt

      data_map.set( BCRYPT_SALT_KEY_NAME, bcrypt_salt )
      data_map.set( PBKDF2_SALT_KEY_NAME, pbkdf2_salt )

      return derive_and_amalgamate( human_secret, bcrypt_salt, pbkdf2_salt )

    end


    # Regenerate the viciously unretrievable nor reversable key that was
    # generated in the past and with the same salts that were used during
    # the original key derivation process.
    #
    # @param data_map [Hash]
    #    an instantiated and populated hash object containing the salts
    #    which were created in the past during the generation. These are
    #    now vital for a successful regeneration.
    #
    # @return [Key]
    #    the 256 bit symmetric encryption key that was previously generated
    #    from the secret and the cryptographic salts within the data_map.
    def self.regenerate_from_salts human_secret, data_map

      bcrypt_salt = data_map.get( BCRYPT_SALT_KEY_NAME )
      pbkdf2_salt = data_map.get( PBKDF2_SALT_KEY_NAME )

      return derive_and_amalgamate( human_secret, bcrypt_salt, pbkdf2_salt )

    end



    private



    def self.derive_and_amalgamate( human_secret, bcrypt_salt, pbkdf2_salt )

      bcrypt_key = KdfBCrypt.generate_key( human_secret, bcrypt_salt )
      pbkdf2_key = KeyPbkdf2.generate_key( human_secret.reverse, pbkdf2_salt )

      assert_bcrypt_key_bit_length bcrypt_key
      assert_pbkdf2_key_bit_length pbkdf2_key

      amalgam_key = Key.new ( bcrypt_key.to_s[ 0 .. (BCRYPT_KEY_CONTRIBUTION_SIZE-1) ] + pbkdf2_key.to_s[ 0 .. (PBKDF2_KEY_CONTRIBUTION_SIZE-1) ] )

      assert_amalgam_key_bit_length amalgam_key

      return amalgam_key

    end


    def self.assert_bcrypt_key_bit_length bcrypt_key
      bcrypt_key_bit_length = bcrypt_key.to_s.bytesize
      bcrypt_keysize_msg = "Expecting #{KdfBCrypt::BCRYPT_KEY_EXPORT_BIT_LENGTH} not #{bcrypt_key_bit_length} bits in bcrypt key."
      raise RuntimeError, bcrypt_keysize_msg unless bcrypt_key_bit_length == KdfBCrypt::BCRYPT_KEY_EXPORT_BIT_LENGTH
    end


    def self.assert_pbkdf2_key_bit_length pbkdf2_key
      pbkdf2_key_bit_length = pbkdf2_key.to_s.bytesize
      pbkdf2_keysize_msg = "Expecting #{KeyPbkdf2::PBKDF2_EXPORT_BIT_LENGTH} not #{pbkdf2_key_bit_length} bits in pbkdf2 key."
      raise RuntimeError, pbkdf2_keysize_msg unless pbkdf2_key_bit_length == KeyPbkdf2::PBKDF2_EXPORT_BIT_LENGTH
    end


    def self.assert_amalgam_key_bit_length amalgam_key

      amalgam_key_bit_length = amalgam_key.to_s.bytesize
      amalgam_keysize_msg = "Expecting #{AMALGAM_KEY_RAW_BIT_SIZE} not #{amalgam_key_bit_length} bits in amalgam key."
      raise RuntimeError, amalgam_keysize_msg unless amalgam_key_bit_length == AMALGAM_KEY_RAW_BIT_SIZE
    end


  end


end
