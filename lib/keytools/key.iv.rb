#!/usr/bin/ruby

module OpenKey

  # Create and deliver representations of a random initialization vector
  # suitable for the AES symmetric encryption algorithm which demands a
  # 18 byte binary string.
  #
  # The initialization vector is sourced from {SecureRandom} which provides
  # a highly random (and secure) byte sequence usually sourced from udev-random.
  #
  #   + ------------------ + -------- + ------------ + ------------------- +
  #   | Random IV Format   | Bits     | Bytes        | Base64              |
  #   | ------------------ | -------- | ------------ | ------------------- |
  #   | Random IV Stored   | 192 Bits | 24 bytes     | 32 characters       |
  #   | Random IV Binary   | 128 Bits | 16 bytes     | (not stored)        |
  #   + ------------------ + -------- + ------------ + ------------------- +
  #
  # This table shows that the initialization vector can be represented by
  # both a <b>32 character base64 string</b> suitable for storage and a
  # <b>18 byte binary</b> for feeding the algorithm.
  class KeyIV


    # The 24 random bytes is equivalent to 192 bits which when sliced into 6 bit
    # blocks (one for each base64 character) results in 32 base64 characters.
    NO_OF_BASE64_CHARS = 32

    # We ask for 24 secure random bytes that are individually created to ensure
    # we get exactly the right number.
    NO_OF_SOURCE_BYTES = 24

    # We truncate the source random bytes so that 16 bytes are returned for the
    # random initialization vector.
    NO_OF_BINARY_BYTES = 16


    # Initialize an initialization vector from a source of random bytes
    # which can then be presented in both a <b>(base64) storage</b> format
    # and a <b>binary string</b> format.
    #
    #   + ------------------ + -------- + ------------ + ------------------- +
    #   | Random IV Format   | Bits     | Bytes        | Base64              |
    #   | ------------------ | -------- | ------------ | ------------------- |
    #   | Random IV Stored   | 192 Bits | 24 bytes     | 32 characters       |
    #   | Random IV Binary   | 128 Bits | 16 bytes     | (not stored)        |
    #   + ------------------ + -------- + ------------ + ------------------- +
    #
    # We ask for 24 secure random bytes that are individually created to ensure
    # we get exactly the right number.
    #
    # If the storage format is requested a <b>32 character base64 string</b> is
    # returned but if the binary form is requested the <b>first 16 bytes</b> are
    # issued.
    def initialize
      @bit_string = Key.to_random_bits( NO_OF_SOURCE_BYTES )
    end


    # When the storage format is requested a <b>32 character base64 string</b> is
    # returned - created from the initialized 24 secure random bytes.
    #
    #   + ---------------- + -------- + ------------ + ------------------- +
    #   | Random IV Stored | 192 Bits | 24 bytes     | 32 characters       |
    #   + ---------------- + -------- + ------------ + ------------------- +
    #
    # @return [String]
    #    a <b>32 character base64 formatted string</b> is returned.
    def for_storage
      return Key64.from_bits( @bit_string )
    end


    #
    #   + ---------------- + -------- + ------------ + ------------------- +
    #   | Random IV Binary | 128 Bits | 16 bytes     | (not stored)        |
    #   + ---------------- + -------- + ------------ + ------------------- +
    #
    # @param iv_base64_chars [String]
    #    the 32 characters in base64 format that will be converted into a binary
    #    string (24 byte) representation and then truncated to 16 bytes and outputted
    #    in binary form.
    #
    # @return [String]
    #    a <b>16 byte binary string</b> is returned.
    #
    # @raise [ArgumentError]
    #    if a <b>32 base64 characters</b> are not presented in the parameter.
    def self.in_binary iv_base64_chars

      b64_msg = "Expected #{NO_OF_BASE64_CHARS} base64 chars not #{iv_base64_chars.length}."
      raise ArgumentError, b64_msg unless iv_base64_chars.length == NO_OF_BASE64_CHARS

      binary_string = Key.to_binary_from_bit_string( Key64.to_bits( iv_base64_chars ) )

      bin_msg = "Expected #{NO_OF_SOURCE_BYTES} binary bytes not #{binary_string.length}."
      raise RuntimeError, bin_msg unless binary_string.length == NO_OF_SOURCE_BYTES

      return binary_string[ 0 .. ( NO_OF_BINARY_BYTES - 1 ) ]

    end


  end


end
