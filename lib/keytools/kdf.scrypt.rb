#!/usr/bin/ruby
# coding: utf-8

module SafeDb


  # SCrypt is a <b>Key Derivation Function (KDF)</b> with a reliable OpenSSL
  # implementation that converts <b>low entropy</b> password-like text to a
  # high entropy key that is computationally infeasible to acquire through brute
  # force.
  #
  # SCrypt is incredibly resistant to attacks using dedicated hardware with
  # massive memory to boot.
  #
  class KdfSCrypt

    # SCrypt salts are recommended to contain 16 and 32 bytes
    # inclusive. Here we opt for 24 bytes which unrolls out to
    # 192 bits which serializes into 32 base64 characters.
    SCRYPT_SALT_BYTE_LENGTH = 24

    # The iteration count is determined using the powers of
    # two so if the iteration integer is 12 there will be two
    # to the power of 12 ( 2^12 ) giving 4096 iterations.
    # The minimum number is 4 (16 iterations) and the max is 31.
    # @example
    #    Configuring 16 into this directive results in
    #       2^16 = 65,536 iterations
    #
    #    This is a safe default and will slow the derivation time
    #    to about a second on a powerful 2020 laptop.
    SCRYPT_ITERATION_INTEGER = 16

    # The scrypt algorithm produces a key that is 181 bits in
    # length. The algorithm then converts the binary 181 bits
    # into a (6-bit) Radix64 character.
    #
    # 181 / 6 = 30 remainder 1 (so 31 characters are needed).
    SCRYPT_KEY_LENGTH = 31
    

    # When the key is transported using a 64 character set where
    # each character is represented by 6 bits - the Scrypt key
    # expands to 186 bits rather than the original 181 bits.
    #
    # This expansion is because of the remainder.
    #
    #    181 bits divided by 6 is 30 characters plus 1 character
    #    for the extra bit.
    #
    #    The 31 transported characters then appear as
    #    31 times 6 which equals 186 bits.
    SCRYPT_KEY_TRANSPORT_LENGTH = 186
    
    # The scrypt algorithm salt string should be 22 characters
    # and may include forward slashes and periods.
    SCRYPT_SALT_LENGTH = 22

    # Scrypt outputs a single line of text that holds the prefix
    # then the Radix64 encoded salt and finally the Radix64
    # encoded hash key.
    #
    # The prefix consists of <b>two sections</b> sandwiched within
    # two dollar <b>$</b> signs at the extremeties and a third dollar
    # separating them.
    #
    # The two sections are the
    # - Scrypt algorithm <b>version number</b> (2a or 2b) and
    # - a power of 2 integer defining the no. of interations
    SCRYPT_OUTPUT_TEXT_PREFIX = "$2a$#{SCRYPT_ITERATION_INTEGER}$"


    # Generate a secure random and unpredictable salt suitable for
    # the SCrypt algorithm. SCrypt salts are recommended to contain
    # 16 and 32 bytes inclusive. Here we opt for 24 bytes which
    # unrolls to 192 bits which in turn is 32 base64 characters.
    #
    # The {SafeDb::KdfSCrypt::SCRYPT_SALT_BYTE_LENGTH} constant
    # defines the <b>number of random bytes</b> required for a robust
    # SCrypt salt.
    #
    # The salt can be persisted and then resubmitted in order to
    # regenerate the same key in the future.
    #
    # @return [String]
    #    the salt in a bit string format which can be converted to
    #    in order to feed the derivation function or indeed converted
    #    to base64 in order to persist it.
    def self.generate_scrypt_salt
      return Key.to_random_bits( SCRYPT_SALT_BYTE_LENGTH )
    end



    # Key generators should first use the {generate_salt} method to create
    # a Scrypt salt string and then submit it to this method together with
    # a human generated password in order to derive a key.
    #
    # The salt can be persisted and then resubmitted again to this method
    # in order to regenerate the same key at any time in the future.
    #
    # Generate a binary key from the scrypt password derivation function.
    #
    # This differs from a server side password to hash usage in that we
    # are interested in the 186bit key that scrypt produces. This method
    # returns this reproducible key for use during symmetric encryption and
    # decryption.
    #
    # @param secret_text [String]
    #    a robust human generated password with as much entropy as can
    #    be mustered. Remember that 40 characters spread randomly over
    #    the key space of about 90 characters and not relating to any
    #    dictionary word or name is the way to generate a powerful key
    #    that has embedded a near 100% entropy rating.
    #
    # @param scrypt_salt [String]
    #    the salt string that has either been recently generated via the
    #    {generate_salt} method or read from a persistence store and
    #    resubmitted here (in the future) to regenerate the same key.
    #
    # @return [Key]
    #    a key holder containing the key which can then be accessed via
    #    many different formats.
    def self.generate_key secret_text, scrypt_salt

      binary_salt = Key.to_binary_from_bit_string( scrypt_salt )

      require "openssl"

      puts ""
      puts $LOADED_FEATURES.grep(/openssl/)
      puts ""

      scrypt_key = OpenSSL::KDF.scrypt(secret_text, salt: binary_salt, N: 2**SCRYPT_ITERATION_INTEGER, r: 8, p: 1, length: 33)



=begin
      hashed_secret = Scrypt::Engine.hash_secret( secret_text, to_scrypt_salt(scrypt_salt) )
      encoded64_key = Scrypt::Password.new( hashed_secret ).to_s
      key_begin_index = SCRYPT_OUTPUT_TEXT_PREFIX.length + SCRYPT_SALT_LENGTH
      radix64_key_str = encoded64_key[ key_begin_index .. -1 ]
      key_length_mesg = "The scrypt key length should have #{SCRYPT_KEY_LENGTH} characters."
      raise RuntimeError, key_length_mesg unless radix64_key_str.length == SCRYPT_KEY_LENGTH

      return Key.new(radix64_key_str)
=end
      return scrypt_key
    end



    private


    def self.scrypt_test_method

      puts ""
      puts "##############################################################################"

      key_count = 20
      for n in 0 .. key_count
        scrypt_saltbits = SafeDb::KdfSCrypt.generate_scrypt_salt
        scrypt_key = SafeDb::KdfSCrypt.generate_key( "abonekanoby", scrypt_saltbits )
        scrypt_saltchar = SafeDb::Key64.from_bits( scrypt_saltbits )
        puts "#{n} Salt => #{scrypt_saltchar} (#{scrypt_saltchar.length}) => Key => #{scrypt_key} (#{scrypt_key.length})"
      end

      puts "##############################################################################"
      puts ""

    end



    def self.to_scrypt_salt the_salt
      return SCRYPT_OUTPUT_TEXT_PREFIX + the_salt
    end

    def self.assert_scrypt_salt the_salt
      raise RuntimeError, "scrypt salt not expected to be nil." if the_salt.nil?
      salt_length_msg = "A scrypt salt is expected to contain #{SCRYPT_SALT_LENGTH} characters."
      raise RuntimeError, salt_length_msg unless the_salt.length == SCRYPT_SALT_LENGTH
    end


  end


end
