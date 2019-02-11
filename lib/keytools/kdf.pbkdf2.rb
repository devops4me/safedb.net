#!/usr/bin/ruby
# coding: utf-8

module OpenKey


  # PBKDF2 is a powerful leading <b>Key Derivation Function (KDF)</b> that exists to
  # convert <b>low entropy</b> human created passwords into a high entropy key that
  # is computationally infeasible to acquire through brute force.
  #
  # As human generated passwords have a relatively small key space, key derivation
  # functions must be slow to compute with any implementation.
  #
  # PBKDF2 offers an <b>iteration count</b> that configures the number of iterations
  # performed to create the key.
  #
  # <b>One million (1,000,000) should be the iteration count's lower bound.</b>
  #
  # == Upgrading the OpenSSL <em>pbkdf2_hmac</em> Behaviour
  #
  # As soon as the new Ruby and OpenSSL libraries become commonplace this class should
  # be upgraded to use the <b>new and improved {OpenSSL::KDF.pbkdf2_hmac} behaviour</b>
  # rather than {OpenSSL::PKCS5.pbkdf2_hmac}.
  #
  # The difficulty is in detecting the operating system's C libraries that are directly
  # accessed for OpenSSL functionality. If the distinction can be made accurately, those
  # with newer libraries can reap the benefits immediately.
  #
  # == PBKDF2 Cost Iteration Timings on an Intel i-5 Laptop
  #
  # An IBM ThinkPad was used to generate the timings.
  #
  #    Memory RAM ~> 15GiB
  #    Processors ~> Intel(R) Core(TM) i5-7200U CPU @ 2.50GHz
  #
  # The timing results show that a prudent value is somewhere
  # between one hundred thousand and ten million iterations.
  #
  #    9.6   seconds for 10,000,000 ten million iterations
  #    0.96  seconds for  1,000,000 one million iterations
  #    0.096 seconds for    100,000 one hundred thousand iterations
  #
  # Open key sets iteration counts for PBKDF2 in hexadecimal and
  # a valid range starts at 1 and counts up in chunks of a hundred
  # thousand (100,000).
  #
  #      1    ~>      100,000
  #      5    ~>      500,000
  #      10   ~>    1,000,000
  #      16   ~>   16,000,000
  #      256  ~>  256,000,000
  #
  # The maximum iteration multiplier allowed is 16,384.
  class KeyPbkdf2


    # <b>One million iterations</b> is necessary due to the
    # growth of <b>GPU driven cloud based computing</b> power
    # that is curently being honed by mining BitCoin and training
    # neural networks.
    #
    # == PBKDF2 Cost Iteration Timings on an Intel i-5 Laptop
    #
    # An IBM ThinkPad was used to generate the timings.
    #
    #    Memory RAM ~> 15GiB
    #    Processors ~> Intel(R) Core(TM) i5-7200U CPU @ 2.50GHz
    #
    # The timing results show that a prudent value is somewhere
    # between one hundred thousand and ten million iterations.
    #
    # Open key sets iteration counts for PBKDF2 in hexadecimal and
    # a valid range starts at 1 and counts up in chunks of a hundred
    # thousand (100,000).
    #
    #      1    ~>      100,000
    #      5    ~>      500,000
    #      10   ~>    1,000,000
    #      16   ~>   16,000,000
    #      256  ~>  256,000,000
    PBKDF2_ITERATION_MULTIPLIER = 1

    # The quantity used to multiply the iteration multiplier by to
    # gain the iteration count.
    ONE_HUNDRED_THOUSAND = 100000


    # Documentation for this algorithm says this about the key length.
    #
    # Make the key length <b>larger than or equal to the output length</b>
    # of the <b>underlying digest function</b>, otherwise an attacker could
    # simply try to brute-force the key.
    #
    # According to PKCS#5, security is limited by the output length of
    # the underlying digest function, i.e. security is not improved if a
    # key length strictly larger than the digest output length is chosen.
    #
    # Therefore, when using PKCS5 for password storage, it suffices to
    # store values equal to the digest output length, nothing is gained
    # by storing larger values.
    PBKDF2_EXPORT_KEY_LENGTH = OpenSSL::Digest::SHA384.new.digest_length


    # For a 384 bit digest the key length is 48 bytes and the bit length
    # is 384 bits.
    PBKDF2_EXPORT_BIT_LENGTH = PBKDF2_EXPORT_KEY_LENGTH * 8


    # The documented recommended salt length in bytes for the PBKDF2
    # algorithm is between <b>16 and 24 bytes</b>. The setting here is
    # at the upper bound of that range.
    PBKDF2_SALT_LENGTH_BYTES = 24


    # Return a random cryptographic salt generated from twenty-four
    # random bytes produced by a secure random number generator. The
    # returned salt is primarily a Base64 encoded string that can be
    # stored and then passed to the {KeyPbkdf2.generate_key} method.
    #
    #    + ------------ + -------- + ------------ + ------------- +
    #    |              | Bits     | Bytes        | Base64        |
    #    | ------------ | -------- | ------------ | ------------- |
    #    | PBKDF2 Salt  | 192 Bits | 24 bytes     | 32 characters |
    #    + ------------ + -------- + ------------ + ------------- +
    #
    # The leading part of the character sequence indicates the length
    # of the salt in chunks of 100,000 and is plus sign separated.
    #
    #     42+12345678abcdefgh12345678ABCDEFGH ~>  4,200,000 iterations
    #      9+12345678abcdefgh12345678ABCDEFGH ~>    900,000 iterations
    #    100+12345678abcdefgh12345678ABCDEFGH ~> 10,000,000 iterations
    #
    # Note that the generate key method will convert the trailing 32
    # base64 characters back into a <b>24 byte binary</b> string.
    #
    # @return [String]
    #    a relatively small iteration count multiplier separated from the
    #    main salt characters by a plus sign. The salt characters will
    #    consist of 32 base64 characters which can be stored and fed into
    #    the {generate_key}.
    #
    #    These 32 characters are a representation of the twenty-four (24)
    #    randomly and securely generated bytes.
    def self.generate_pbkdf2_salt

      pbkdf2_salt = Key64.from_bits( Key.to_random_bits( PBKDF2_SALT_LENGTH_BYTES ) )
      return "#{PBKDF2_ITERATION_MULTIPLIER}+#{pbkdf2_salt}"

    end


    # Generate a 128 bit binary key from the PBKDF2 password derivation
    # function. The most important input to this function is the human
    # generated key. The best responsibly sourced key with at least 95%
    # entropy will contain about 40 characters spread randomly over the
    # set of 95 typable characters.
    #
    # Aside from the human password the other inputs are
    #
    # - a base64 encoded randomly generated salt of 16 to 24 bytes
    # - an iteration count of at least 1 million (due to GPU advances)
    # - an output key length that is at least 16 bytes (128 bits)
    # - a digest algorithm implementation (we use SHA512K)
    #
    # The {Key} returned by this method encapsulates the derived
    # key of the byte (bit) length specified.
    #
    # <b>PBKDF2 Output Key Length Note</b>
    #
    # Documentation for this algorithm says this about the key length.
    #
    #    Typically, the key length should be larger than or equal to the
    #    output length of the underlying digest function, otherwise an
    #    attacker could simply try to brute-force the key. According to
    #    PKCS#5, security is limited by the output length of the underlying
    #    digest function, i.e. security is not improved if a key length
    #    strictly larger than the digest output length is chosen.
    #
    #    Therefore, when using PKCS5 for password storage, it suffices to
    #    store values equal to the digest output length, nothing is gained
    #    by storing larger values.
    #
    # <b>Upgrading the OpenSSL <em>pbkdf2_hmac</em> Behaviour</b>
    #
    # As soon as the new Ruby and OpenSSL libraries become commonplace this class should
    # be upgraded to use the <b>new and improved {OpenSSL::KDF.pbkdf2_hmac} behaviour</b>
    # rather than {OpenSSL::PKCS5.pbkdf2_hmac}.
    #
    # The difficulty is in detecting the operating system's C libraries that are directly
    # accessed for OpenSSL functionality. If the distinction can be made accurately, those
    # with newer libraries can reap the benefits immediately.
    #
    # @param human_secret [String]
    #    a robust human generated password with as much entropy as can
    #    be mustered. Remember that 40 characters spread randomly over
    #    the key space of about 95 characters and not relating to any
    #    dictionary word or name is the way to generate a powerful key
    #    that has embedded a near 100% entropy rating.
    #
    # @param pbkdf2_string [String]
    #    this is a relatively small iteration count multiplier separated
    #    from the main salt characters by a plus sign. The salt characters
    #    will consist of 32 base64 characters which can be stored and fed
    #    into the {generate_key}.
    #
    #    The salt string presented here must have either been recently
    #    generated by {generate_pbkdf2salt} or read from a persistence
    #    store and resubmitted here in order to regenerate the same key.
    #
    # @return [Key]
    #    a key holder containing the key which can then be accessed via
    #    many different formats. The {Key} returned by this method
    #    encapsulates the derived key with the specified byte count.
    def self.generate_key human_secret, pbkdf2_string

      KeyError.not_new pbkdf2_string, "PBKDF2 Algorithm Salt"
      multiplier = pbkdf2_string.split("+")[0].to_i
      pbkdf2_salt = pbkdf2_string.split("+")[1]

      mult_msg = "Iteration multiplier is an integer from 1 to 16,384 not [#{multiplier}]."
      raise ArgumentError, mult_msg_msg unless( multiplier > 0 && multiplier < 16385 )
      iteration_count = multiplier * ONE_HUNDRED_THOUSAND

      binary_salt = Key.to_binary_from_bit_string( Key64.to_bits( pbkdf2_salt ) )
      err_msg = "Expected salt of #{PBKDF2_SALT_LENGTH_BYTES} bytes not #{binary_salt.length}."
      raise ArgumentError, err_msg unless binary_salt.length == PBKDF2_SALT_LENGTH_BYTES

      pbkdf2_key = OpenSSL::PKCS5.pbkdf2_hmac(
        human_secret,
        binary_salt,
        iteration_count,
        PBKDF2_EXPORT_KEY_LENGTH,
        OpenSSL::Digest::SHA384.new
      )

      return Key.from_binary( pbkdf2_key )

    end


    private


    # ---
    # --- Timings Code
    # ---
    # --- chopped_radix64_key = NIL
    # --- require 'benchmark'
    # --- timings = Benchmark.measure {
    # ---
    # ---     -- wrapped up code block
    # ---
    # --- }
    # ---
    # --- log.info(x) { "PBKDF2 key generation timings ~> #{timings}" }
    # ---


  end


end
