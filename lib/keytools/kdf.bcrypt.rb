#!/usr/bin/ruby
# coding: utf-8

module OpenKey

  # BCrypt is a <b>Blowfish based Key Derivation Function (KDF)</b> that exists to
  # convert <b>low entropy</b> human created passwords into a high entropy key that
  # is computationally infeasible to acquire through brute force.
  #
  # As human generated passwords have a relatively small key space, key derivation
  # functions must be slow to compute with any implementation.
  #
  # BCrypt offers a <b>cost parameter</b> that determines (via the powers of two)
  # the number of iterations performed.
  #
  # If the cost parameter is 12, then 4096 iterations (two to the power of 12) will
  # be enacted.
  #
  # == A Cost of 16 is 65,536 iterations
  #
  # The <b>minimum cost</b> is 4 (16 iterations) and the maximum is 31.
  #
  # <b>A cost of 16 will result in 2^16 = 65,536 iterations</b> and will slow the
  # derivation time to about a second on a powerful 2020 laptop.
  #
  # == BCrypt Cost Iteration Timings on an Intel i-5 Laptop
  #
  # The benchmark timings were incredibly consistent and
  # took almost exactly twice as long for every step.
  #
  # An IBM ThinkPad was used to generate the timings.
  #
  #    Memory RAM ~> 15GiB
  #    Processors ~> Intel(R) Core(TM) i5-7200U CPU @ 2.50GHz
  #
  # The timing results (for 2 steps) multiplied by four (4).
  #
  #    3.84 seconds for 2^16 (65,536) iterations
  #    0.96 seconds for 2^14 (16,384) iterations
  #    0.24 seconds for 2^12 ( 4,096) iterations
  #    0.06 seconds for 2^10 ( 1,024) iterations
  #
  # A double digit iteration cost must be provided to avoid
  # an in-built failure trap. The default cost is now 10.
  class KdfBCrypt

    require "bcrypt"

    # The iteration count is determined using the powers of
    # two so if the iteration integer is 12 there will be two
    # to the power of 12 ( 2^12 ) giving 4096 iterations.
    # The minimum number is 4 (16 iterations) and the max is 31.
    #
    # @example
    #    Configuring 16 into this directive results in
    #       2^16 = 65,536 iterations
    #
    # == BCrypt Cost Iteration Timings on an Intel i-5 Laptop
    #
    # The benchmark timings were incredibly consistent and
    # took almost exactly twice as long for every step.
    #
    # An IBM ThinkPad was used to generate the timings.
    #
    #    Memory RAM ~> 15GiB
    #    Processors ~> Intel(R) Core(TM) i5-7200U CPU @ 2.50GHz
    #
    # The timing results (for 2 steps) multiplied by four (4).
    #
    #    3.84 seconds for 2^16 (65,536) iterations
    #    0.96 seconds for 2^14 (16,384) iterations
    #    0.24 seconds for 2^12 ( 4,096) iterations
    #    0.06 seconds for 2^10 ( 1,024) iterations
    #
    # A double digit iteration cost must be provided to avoid
    # an in-built failure trap. The default cost is now 10.
    BCRYPT_ITERATION_INTEGER = 10

    # The bcrypt algorithm produces a key that is 181 bits in
    # length. The algorithm then converts the binary 181 bits
    # into a (6-bit) Radix64 character.
    #
    # 181 / 6 = 30 remainder 1 (so 31 characters are needed).
    BCRYPT_KEY_LENGTH = 31

    # BCrypt key derivation (from text) implementations truncate
    # the first 55 characters of the incoming text.
    BCRYPT_MAX_IN_TEXT_LENGTH = 55

    # The BCrypt algorithm produces 181 raw binary bits which is just
    # one bit more than a 30 character base64 string. Hence the algorithm
    # puts out 31 characters.
    #
    # We discard the 31st character because 5 of its 6 bits are 100%
    # predictable. Thus the returned key will contribute 180 bits.
    BCRYPT_KEY_EXPORT_BIT_LENGTH = 180
    
    # The BCrypt algorithm salt string should be 22 characters
    # and may include forward slashes and periods.
    BCRYPT_SALT_LENGTH = 22

    # BCrypt outputs a single line of text that holds the prefix
    # then the Radix64 encoded salt and finally the Radix64
    # encoded hash key.
    #
    # The prefix consists of <b>two sections</b> sandwiched within
    # two dollar <b>$</b> signs at the extremeties and a third dollar
    # separating them.
    #
    # The two sections are the
    # - BCrypt algorithm <b>version number</b> (2a or 2b) and
    # - a power of 2 integer defining the no. of interations
    BCRYPT_OUTPUT_TEXT_PREFIX = "$2x$#{BCRYPT_ITERATION_INTEGER}$"


    # Key generators should use this method to create a BCrypt salt
    # string and then call the {generate_key} method passing in the
    # salt together with a human generated password in order to derive
    # a key.
    #
    # The salt can be persisted and then resubmitted in order to
    # regenerate the same key in the future.
    #
    # For the BCrypt algorithm this method depends on the constant
    # {BCRYPT_ITERATION_INTEGER} so that two to the power of the
    # integer is the number of iterations.
    #
    # A generated salt looks like this assuming the algorithm version
    # is 2a and the interation integer is 16.
    #
    # <b>$2a$16$nkyYKCwljFRtcif6FCXn3e</b>
    #
    # This method removes the $2a$16$ preamble string and stores only
    # the actual salt string whose length should be 22 characters.
    #
    # <b>Why do BCrypt salts always end with zero, e, u or period</b>?
    #
    # Two <b>(2) leftover bits</b> is the short answer.
    #
    # This is because the salts are a random 16 bytes and must be
    # stored in base64. The 16 bytes equals 128bits which when converted
    # to base64 (6bits per character) results in 21 characters and only
    # two leftover bits.
    #
    #    BCrypt Salt => t4bDqoJlHbb/k7bkt4/1Ku (22 characters)
    #    BCrypt Salt => 9BjuJU67IG9Lz5tYUhOqeO (22 characters)
    #    BCrypt Salt => grz.QREI35585Y3AaCoCTe (22 characters)
    #    BCrypt Salt => zsxrVW2RGIltSu.AoS4E7e (22 characters)
    #    BCrypt Salt => dTlRJZ6ijDDVk2cFoCQHPO (22 characters)
    #    BCrypt Salt => S9B1azH7oD8L3.CQfxxzJO (22 characters)
    #    BCrypt Salt => LoZh.q3NdnTIuOmR6gHJF. (22 characters)
    #    BCrypt Salt => y6DKk23SmgNR863pTZ8nYe (22 characters)
    #    BCrypt Salt => rokdUF6tg6wHV6F0ymKFme (22 characters)
    #    BCrypt Salt => jrDpNgh.0OEIYaxsR7E7d. (22 characters)
    #
    # Don't forget BCrypt uses Radix64 (from OpenBSD). So the two (2)
    # leftover bits result in 4 possible values which effectively is
    #
    #        a period (.)
    #        a zero   (0)
    #        an e     (e)
    #        or a u   (u)
    #
    # @return [String]
    #    the salt in a printable format like base64, hex or a string
    #    of ones and zeroes. This salt should be submitted in the exact
    #    same form to the {generate_key} method.
    def self.generate_bcrypt_salt

      full_bcrypt_salt = BCrypt::Engine.generate_salt( BCRYPT_ITERATION_INTEGER )
      main_bcrypt_salt = full_bcrypt_salt[ BCRYPT_OUTPUT_TEXT_PREFIX.length .. -1 ]
      keep_bcrypt_salt = "#{BCRYPT_ITERATION_INTEGER}#{main_bcrypt_salt}"
      assert_bcrypt_salt( keep_bcrypt_salt )
      return keep_bcrypt_salt

    end


    # Key generators should first use the {generate_salt} method to create
    # a BCrypt salt string and then submit it to this method together with
    # a human generated password in order to derive a key.
    #
    # The salt can be persisted and then resubmitted again to this method
    # in order to regenerate the same key at any time in the future.
    #
    # Generate a binary key from the bcrypt password derivation function.
    #
    # This differs from a server side password to hash usage in that we
    # are interested in the 186bit key that bcrypt produces. This method
    # returns this reproducible key for use during symmetric encryption and
    # decryption.
    #
    # @param human_secret [String]
    #    a robust human generated password with as much entropy as can
    #    be mustered. Remember that 40 characters spread randomly over
    #    the key space of about 90 characters and not relating to any
    #    dictionary word or name is the way to generate a powerful key
    #    that has embedded a near 100% entropy rating.
    #
    # @param bcrypt_salt [String]
    #    the salt string that has either been recently generated via the
    #    {generate_salt} method or read from a persistence store and
    #    resubmitted here (in the future) to regenerate the same key.
    #
    # @return [Key]
    #    an {OpenKey::Key} that has been initialized from the 30 RADIX64
    #    character output from the BCrypt algorithm.
    #
    #    The BCrypt algorithm produces 181 raw binary bits which is just
    #    one bit more than a 30 character base64 string. Hence the algorithm
    #    puts out 31 characters.
    #
    #    We discard the 31st character because 5 of its 6 bits are 100%
    #    predictable. Thus the returned key will contribute 180 bits.
    def self.generate_key human_secret, bcrypt_salt

      iteration_int = bcrypt_salt[ 0 .. 1 ]
      bcrypt_prefix = "$2x$#{iteration_int}$"
      full_salt_str = bcrypt_prefix + bcrypt_salt[ 2 .. -1 ]

      assert_bcrypt_salt( bcrypt_salt )

      hashed_secret = BCrypt::Engine.hash_secret( human_secret, full_salt_str )
      encoded64_key = BCrypt::Password.new( hashed_secret ).to_s
      key_begin_index = BCRYPT_OUTPUT_TEXT_PREFIX.length + BCRYPT_SALT_LENGTH
      radix64_key_str = encoded64_key[ key_begin_index .. -1 ]
      key_length_mesg = "The BCrypt key length should have #{BCRYPT_KEY_LENGTH} characters."
      raise RuntimeError, key_length_mesg unless radix64_key_str.length == BCRYPT_KEY_LENGTH
      chopped_radix64_key = radix64_key_str.chop()

      return Key.from_radix64( chopped_radix64_key )

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
    # --- log.info(x) { "BCrypt key generation timings ~> #{timings}" }
    # ---


    def self.assert_bcrypt_salt the_salt
      raise RuntimeError, "bcrypt salt not expected to be nil." if the_salt.nil?
      bcrypt_total_length = 2 + BCRYPT_SALT_LENGTH
      salt_length_msg = "BCrypt salt #{the_salt} is #{the_salt.length} and not #{bcrypt_total_length} characters."
      raise RuntimeError, salt_length_msg unless the_salt.length == bcrypt_total_length
    end


  end


end
