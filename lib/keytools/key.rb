#!/usr/bin/ruby

module SafeDb

  # First use the class methods to source keys, then use a key's instance
  # methods to access its properties and in concert with other symmetrical
  # information, you can use the keys to lock (encrypt) or unlock (decrypt)
  # other keys and objecs.
  #
  # == Sourcing and Deriving Keys
  #
  # Keys can be
  #
  # - sourced from a secure random byte generating function
  # - sourced from ciphertext and another (decryption) key
  # - generated by passing a secret through key derivation functions
  # - regenerated from a secret and previously stored salts
  # - sourced from the current unique workstation shell environment
  # - sourced from an environment variable containing ciphertext
  #
  #
  # Keys need to be viewed (represented) in multiple ways and the essence
  # of the key viewer is to input keys {as_bits}, {as_bytes} and {as_base64}
  # and then output the same key (in as far as is possible) - as bits, as
  # bytes and as base64.
  #
  # == Key | To and From Behaviour
  #
  # Use the <b>From</b> methods to create Keys from a variety of resources
  # such as
  #
  # - a base64 encoded string
  # - a binary byte string
  # - a string of one and zero bits
  # - a hexadecimal representation
  #
  # Once you have instantiated the key, you will then be able to convert it
  # (within reason due to bit, byte and base64 lengths) to any of the above
  # key representations.
  #
  # == Key | Bits Bytes and Base64
  #
  # The shoe doesn't always fit when its on the other foot and this is best
  # illustratd with a table that maps bits to 8 bit bytes and 6 bit Base64
  # characters.
  #
  #   | --------- | -------- | ------------ | ------------------------------- |
  #   | Fit?      | Bits     | Bytes        | (and) Base64                    |
  #   | --------- | -------- | ------------ | ------------------------------- |
  #   | Perfect   | 168 Bits | is 21 bytes  | 28 Chars - bcrypt chops to this |
  #   | Perfect   | 216 Bits | is 27 bytes  | 36 Chars -                      |
  #   | Perfect   | 264 Bits | is 33 bytes  | 44 Chars - holder 4 256bit keys |
  #   | Perfect   | 384 Bits | is 48 bytes  | 64 Chars - 216 + 168 equals 384 |
  #   | --------- | -------- | ------------ | ------------------------------- |
  #   | Imperfect | 128 Bits | 16 precisely | 22 Chars - 21 + 2 remain bits   |
  #   | Imperfect | 186 Bits | 23 remain 2  | 31 Characers precisely          |
  #   | Imperfect | 256 Bits | 32 precisely | 43 Chars - 42 + 4 remain bits   |
  #   | --------- | -------- | ------------ | ------------------------------- |
  #
  # Yes, the shoe doesn't always fit when it's on the other foot.
  #
  # == Schoolboy Error
  #
  # <b>The strategy is so simple, we call it a schoolboy error.</b>
  #
  # If we want to use a key with n bits and either n % 6 or n % 8 (or both)
  # are not zero - <b>we instantiate a Key</b> with the lowest common
  # denominator of 6 and 8 that exceeds n.
  #
  # So when we request a byte, or base64 representation the viewer will
  # truncate (not round down) to the desired length.
  #
  # == Mapping Each Character to 6 Binary Bits
  #
  # We need 6 binary bits to represent a base64 character (and 4
  # bits for hexadecimal). Here is an example mapping between
  # a base 64 character, an integer and the six bit binary.
  #
  #    Character   Integer  Binary (6 Bit)
  #
  #       a           0        000000
  #       b           1        000001
  #       c           2        000010
  #
  #       y           25       011001
  #       z           26       011010
  #       A           27       011011
  #       B           28       011100
  #
  #       8           60       111100
  #       9           61       111101
  #       /           62       111110
  #       +           63       111111
  #
  class Key

    # Initialize a key object from a bit string of ones and zeroes provided
    # in the parameter string.
    #
    # For example a string of 384 bits (ones and zeroes) can be thought of
    # as a 48 byte key which can also be represented with 64 more compact
    # base64 characters.
    #
    #   | -------- | ------------ | -------------------------------- |
    #   | Bits     | Bytes        | Base64                           |
    #   | -------- | ------------ | -------------------------------- |
    #   | 384 Bits | is 48 bytes  | and 64 characters                |
    #   | -------- | ------------ | -------------------------------- |
    #
    # @param the_bit_string [String]
    #    the bit string of ones and zeroes that represents the bits that
    #    represent this key
    def initialize the_bit_string
      @bit_string = the_bit_string
    end


    # Return a (secure) randomly generated super high entropy 384 bit key
    # that can be stored with <b>64 base64 characters</b> and used to
    # <b><em>source digest functions</em></b> that can unreversibly convert
    # the key to a <b>256 bit symmetric encryption key</b>.
    #
    #   | -------- | ------------ | -------------------------------- |
    #   | Bits     | Bytes        | Base64                           |
    #   | -------- | ------------ | -------------------------------- |
    #   | 384 Bits | is 48 bytes  | and 64 characters                |
    #   | -------- | ------------ | -------------------------------- |
    #
    # This key easily translates to a base64 and/or byte array format because
    # the 384 bit count is a <b>multiple of both 6 and 8</b>.
    #
    # @return [SafeDb::Key]
    #    return a key containing 384 random bits (or a random array of 48 bytes)
    #    which can if necessary be serialized into 64 base64 characters.
    #
    # @raise [ArgumentError]
    #    If a nil or zero length byte array is received.
    #    Or if the number of bytes <b>multiplied by 8</b>
    #    is <b>not a multiple of 6</b>.
    def self.from_random
      return Key.new( to_random_bits( RANDOM_KEY_BYTE_LENGTH ) )
    end


    def self.to_random_bits the_byte_length
      random_bit_string = ""
      for n in 1 .. the_byte_length
        random_integer = SecureRandom.random_number( EIGHT_BIT_INTEGER_SIZE )
        random_bit_string += "%08d" % [ random_integer.to_s(2) ]
      end
      return random_bit_string
    end


    # Return the key represented by the parameter sequence of base64
    # characters.
    #
    # @param char64_string [String]
    #
    #    The base64 character sequence which the returned key is
    #    instantiated from. Naturally this character sequencee cannot
    #    be nil, nor can it contain any characters that are not
    #    present in {Key64::YACHT64_CHARACTER_SET}.
    #
    #    Ideally the number of parameter characters multiplied by 6
    #    <b>should be a multiple of eight (8)</b> otherwise the new
    #    key's bit string will require padding and extension.
    #
    # @return [SafeDb::Key]
    #    return a key from the parameter sequence of base64 characters.
    #
    # @raise [ArgumentError]
    #    If a nil or zero length byte array is received.
    #    Or if the number of bytes <b>multiplied by 8</b>
    #    is <b>not a multiple of 6</b>.
    def self.from_char64 char64_string
      return Key.new( Key64.to_bits( char64_string ) )
    end


    # Return a key represented by the parameter binary string.
    #
    # @param binary_text [String]
    #    The binary string that the returned key will be
    #    instantiated from.
    #
    # @return [SafeDb::Key]
    #    return a key from the binary byte string parameter
    def self.from_binary binary_text
      ones_and_zeroes = binary_text.unpack("B*")[0]
      return Key.new( ones_and_zeroes )
    end


    # Convert a string of Radix64 characters into a key.
    #
    # This method converts the base64 string into the internal YACHT64 format
    # and then converts that into a bit string so that a key can be instantiated.
    #
    # @param radix64_string [String]
    #    the radix64 string to convert into akey. This string will be a subset
    #    of the usual 62 character suspects together with period and forward
    #    slash characters.
    #
    #    This parameter should not contain newlines nor carriage returns.
    #
    # @return [SafeDb::Key]
    #    return a key from the parameter sequence of base64 characters.
    #
    # @raise [ArgumentError]
    #    If a nil or zero length parameter array is received.
    def self.from_radix64 radix64_string
      return Key.new( Key64.from_radix64_to_bits( radix64_string ) )
    end


    # When a key is initialized, it is internally represented as a
    # string of ones and zeroes primarily for simplicity and can be
    # visualized as bits that are either off or on.
    #
    # Once internalized a key can also be represented as
    #
    # - a sequence of base64 (or radix64) characters (1 per 6 bits)
    # - a binary string suitable for encryption (1 byte per 8 bits)
    # - a 256bit encryption key from Digest(ing) the binary form
    #
    # @return [String]
    #    a string of literally ones and zeroes that represent the
    #    sequence of bits making up this key.
    def to_s

      ## Write duplicate ALIAS method called ==> to_bits() <== (bits and pieces)
      ## Write duplicate ALIAS method called ==> to_bits() <== (bits and pieces)
      ## Write duplicate ALIAS method called ==> to_bits() <== (bits and pieces)
      ## Write duplicate ALIAS method called ==> to_bits() <== (bits and pieces)
      ## Write duplicate ALIAS method called ==> to_bits() <== (bits and pieces)
      ## Write duplicate ALIAS method called ==> to_bits() <== (bits and pieces)
      ## Write duplicate ALIAS method called ==> to_bits() <== (bits and pieces)

      ## ---------------------------------------------
      ## +++++++++ WARNING ++++++++
      ## ---------------------------------------------
      ##
      ##      to_s does not need 2b called
      ##      So both the below print the same.
      ##
      ##      So YOU MUST KEEP the to_s method until a proper test suite is in place.
      ##      So YOU MUST KEEP the to_s method until a proper test suite is in place.
      ##
      ##        puts "#{the_key}"
      ##        puts "#{the_key.to_s}"
      ##
      ##      So YOU MUST KEEP the to_s method until a proper test suite is in place.
      ##      So YOU MUST KEEP the to_s method until a proper test suite is in place.
      ##
      ## ---------------------------------------------

      return @bit_string
    end


    # Convert this keys bit value into a printable character set
    # that is suitable for storing in multiple places such as
    # <b>environment variables</b> and <b>INI files</b>.
    #
    # @return [String]
    #    printable characters from a set of 62 alpha-numerics
    #    plus an @ symbol and a percent % sign.
    #
    # @raise ArgumentError
    #    If the bit value string for this key is nil.
    #    Or if the bit string length is not a multiple of six.
    #    Or if it contains any character that is not a 1 or 0.
    def to_char64
      assert_non_nil_bits
      return Key64.from_bits( @bit_string )
    end


    # Return the <b>un-printable <em>binary</em> bytes</b> representation
    # of this key. If you store 128 bits it will produce 22 characters
    # because 128 divide by 6 is 21 characters and a remainder of two (2)
    # bits.
    #
    # The re-conversion of the 22 characters will now produce 132 bits which
    # is different from the original 128 bits.
    #
    # @return [Byte]
    #    a non-printable binary string of eight (8) bit bytes which can be
    #    used as input to both digest and symmetric cipher functions.
    def to_binary
      return [ to_s ].pack("B*")
    end


    # Return the <b>un-printable <em>binary</em> bytes</b> representation
    # of this key. If you store 128 bits it will produce 22 characters
    # because 128 divide by 6 is 21 characters and a remainder of two (2)
    # bits.
    #
    # The re-conversion of the 22 characters will now produce 132 bits which
    # is different from the original 128 bits.
    #
    # @return [Byte]
    #    a non-printable binary string of eight (8) bit bytes which can be
    #    used as input to both digest and symmetric cipher functions.
    def self.to_binary_from_bit_string bit_string_to_convert
      return [ bit_string_to_convert ].pack("B*")
    end


    # This method uses digests to convert the key's binary representation
    # (which is either 48 bytes for purely random keys or 64 bytes for keys
    # derived from human sourced secrets) into a key whose size is ideal for
    # plying the ubiquitous <b>AES256 symmetric encryption algorithm</b>.
    #
    # This method should only ever be called when this key has been derived
    # from either a (huge) <b>48 byte random source</b> or from a key derivation
    # function (KDF) such as BCrypt, SCrypt, PBKDF2 or a union from which the
    # 512 bit (64 byte) key can be reduced to 256 bits.
    #
    # @return [String]
    #    a binary string of thirty-two (32) eight (8) bit bytes which
    #    if appropriate can be used as a symmetric encryption key especially
    #    to the powerful AES256 cipher.
    def to_aes_key
      return Digest::SHA256.digest( to_binary() )
    end


    # This method uses the SHA384 digest to convert this key's binary
    # representation into another (newly instantiated) key whose size
    # is <b>precisely 384 bits</b>.
    #
    # If you take the returned key and call
    #
    # - {to_char64} you get a 64 character base64 string
    # - {to_s} you get a string of 384 ones and zeroes
    # - {to_binary} you get a 48 byte binary string
    #
    # @return [SafeDb::Key]
    #    a key with a bit length (ones and zeroes) of <b>precisely 384</b>.
    def to_384_bit_key

      a_384_bit_key = Key.from_binary( Digest::SHA384.digest( to_binary() ) )

      has_384_chars = a_384_bit_key.to_s.length == 384
      err_msg = "Digested key length is #{a_384_bit_key.to_s.length} instead of 384."
      raise RuntimeError, err_msg unless has_384_chars

      return a_384_bit_key

    end


    # Use the {OpenSSL::Cipher::AES256} block cipher in CBC mode and the binary
    # 256bit representation of this key to encrypt the parameter key.
    #
    # Store the ciphertext provided by this method. To re-acquire (reconstitute)
    # the parameter key use the {do_decrypt_key} decryption method with
    # the ciphertext produced here.
    #
    # <b>Only Encrypt Strong Keys</b>
    #
    # Never encrypt a potentially weak key, like one derived from a human password
    # (even though it is put through key derivation functions).
    #
    # Once generated (or regenerated) a potentially weak key should live only as
    # long as it takes for it to encrypt a strong key. The strong key can then
    # be used to encrypt valuable assets.
    #
    # <b>Enforcing Strong Key Size</b>
    #
    # If one key is potentially weaker than the other, the weaker key must be this
    # object and the strong key is the parameter key.
    #
    # This method thus enforces the size of the strong key. A strong key has
    # 384 bits of entropy, and is represented by 64 base64 characters.
    #
    # @param key_to_encrypt [SafeDb::Key]
    #    this is the key that will first be serialized into base64 and then locked
    #    down using the 256 bit binary string from this host object as the symmetric
    #    encryption key.
    #
    #    This method is sensitive to the size of the parameter key and expects to
    #    encrypt <b>exactly 64 base64 characters</b> within the parameter key.
    #
    # @return [String]
    #    The returned ciphertext should be stored. Its breakdown is as follows.
    #    96 bytes are returned which equates to 128 base64 characters.
    #    The random initialization vector (iv) accounts for the first 16 bytes.
    #    The actual crypt ciphertext then accounts for the final 80 bytes.
    #
    # @raise [ArgumentError]
    #    the size of the parameter (strong) key is enforced to ensure that it has
    #    exactly 384 bits of entropy which are represented by 64 base64 characters.
    def do_encrypt_key key_to_encrypt

      crypt_cipher = OpenSSL::Cipher::AES256.new(:CBC)

      crypt_cipher.encrypt()
      random_iv = crypt_cipher.random_iv()
      crypt_cipher.key = to_aes_key()

      calling_module = File.basename caller_locations(1,1).first.absolute_path, ".rb"
      calling_method = caller_locations(1,1).first.base_label
      calling_lineno = caller_locations(1,1).first.lineno
      caller_details = "#{calling_module} | #{calling_method} | (line #{calling_lineno})"

      cipher_text = crypt_cipher.update( key_to_encrypt.to_char64 ) + crypt_cipher.final

      binary_text = random_iv + cipher_text
      ones_zeroes = binary_text.unpack("B*")[0]
      ciphertxt64 = Key64.from_bits( ones_zeroes )

      size_msg = "Expected bit count is #{EXPECTED_CIPHER_BIT_LENGTH} not #{ones_zeroes.length}."
      raise RuntimeError, size_msg unless ones_zeroes.length == EXPECTED_CIPHER_BIT_LENGTH

      return ciphertxt64

    end


    # Use the {OpenSSL::Cipher::AES256} block cipher in CBC mode and the binary
    # 256bit representation of this key to decrypt the parameter ciphertext and
    # return the previously encrypted key.
    #
    # To re-acquire (reconstitute) the original key call this method with the
    # stored ciphertext that was returned by the {do_encrypt_key}.
    #
    # <b>Only Encrypt Strong Keys</b>
    #
    # Never encrypt a potentially weak key, like one derived from a human password
    # (even though it is put through key derivation functions).
    #
    # Once generated (or regenerated) a potentially weak key should live only as
    # long as it takes for it to encrypt a strong key. The strong key can then
    # be used to encrypt valuable assets.
    #
    # <b>Enforcing Strong Key Size</b>
    #
    # If one key is potentially weaker than the other, the weaker key must be this
    # object and the strong key is reconstituted and returned by this method.
    #
    # @param ciphertext_to_decrypt [String]
    #    Provide the ciphertext produced by our sister key encryption method.
    #    The ciphertext should hold 96 bytes which equates to 128 base64 characters.
    #    The random initialization vector (iv) accounts for the first 16 bytes.
    #    The actual crypt ciphertext then accounts for the final 80 bytes.
    #
    # @return [Key]
    #    return the key that was serialized into base64 and then encrypted (locked down)
    #    with the 256 bit binary symmetric encryption key from this host object.
    #
    # @raise [ArgumentError]
    #    the size of the parameter ciphertext must be 128 base 64 characters.
    def do_decrypt_key ciphertext_to_decrypt

      bit_text = Key64.to_bits(ciphertext_to_decrypt)
      size_msg = "Expected bit count is #{EXPECTED_CIPHER_BIT_LENGTH} not #{bit_text.length}."
      raise RuntimeError, size_msg unless bit_text.length == EXPECTED_CIPHER_BIT_LENGTH

      cipher_x = OpenSSL::Cipher::AES256.new(:CBC)
      cipher_x.decrypt()

      rawbytes = [ bit_text ].pack("B*")

      cipher_x.key = to_aes_key()
      cipher_x.iv  = rawbytes[ 0 .. ( RANDOM_IV_BYTE_COUNT - 1 ) ]
      key_chars_64 = cipher_x.update( rawbytes[ RANDOM_IV_BYTE_COUNT .. -1 ] ) + cipher_x.final

      return Key.from_char64( key_chars_64 )

    end


    # Use the {OpenSSL::Cipher::AES256} block cipher in CBC mode and the binary
    # 256bit representation of this key to encrypt the parameter plaintext using
    # the parameter random initialization vector.
    #
    # Store the ciphertext provided by this method. To re-acquire (reconstitute)
    # the plaintext use the {do_decrypt_text} decryption method, giving
    # it the same initialization vector and the ciphertext produced here.
    #
    # <b>Only Encrypt Once</b>
    #
    # Despite the initialization vector protecting against switch attacks you
    # should <b>only use this or any other key once</b> to encrypt an object.
    # While it is okay to encrypt small targets using two different keys, it
    # pays not to do the same when the target is large.
    #
    # @param random_iv [String]
    #    a randomly generated 16 byte binary string that is to be used as the
    #    initialization vector (IV) - this is a requirement for AES encryption
    #    in CBC mode - this IV does not need to be treated as a secret
    #
    # @param plain_text [String]
    #    the plaintext or binary string to be encrypted. To re-acquire this string
    #    use the {do_decrypt_text} decryption method, giving it the same
    #    initialization vector (provided in the first parameter) and the ciphertext
    #    returned from this method.
    #
    # @return [String]
    #    The returned binary ciphertext should be encoded and persisted until such
    #    a time as its re-acquisition by authorized parties becomes necessary.
    def do_encrypt_text random_iv, plain_text

      crypt_cipher = OpenSSL::Cipher::AES256.new(:CBC)

      crypt_cipher.encrypt()
      crypt_cipher.iv  = random_iv
      crypt_cipher.key = to_aes_key()

      return crypt_cipher.update( plain_text ) + crypt_cipher.final

    end


    # Use the {OpenSSL::Cipher::AES256} block cipher in CBC mode and the binary
    # 256bit representation of this key to decrypt the parameter ciphertext using
    # the parameter random initialization vector.
    #
    # Use this method to re-acquire (reconstitute) the plaintext that was
    # converted to ciphertext by the {do_encrypt_text} encryption method,
    # naturally using the same initialization vector for both calls.
    #
    # <b>Only Decrypt Once</b>
    #
    # Consider <b>a key spent</b> as soon as it decrypts the one object it was
    # created to decrypt. Like a bee dying after a sting, a key should die after
    # it decrypts an object. Should re-decryption be necessary - another key
    # should be derived or generated.
    #
    # @param random_iv [String]
    #    a randomly generated 16 byte binary string that is to be used as the
    #    initialization vector (IV) - this is a requirement for AES decryption
    #    in CBC mode - this IV does not need to be treated as a secret
    #
    # @param cipher_text [String]
    #    the ciphertext or binary string to be decrypted in order to re-acquire
    #    (reconstitute) the plaintext that was converted to ciphertext by the
    #    {do_encrypt_text} encryption method.
    #
    # @return [String]
    #    if the plaintext (or binary string) returned here still needs to be
    #    kept on the low, derive or generate another key to protect it.
    def do_decrypt_text random_iv, cipher_text

      raise ArgumentError, "Incoming cipher text cannot be nil." if cipher_text.nil?

      crypt_cipher = OpenSSL::Cipher::AES256.new(:CBC)

      crypt_cipher.decrypt()
      crypt_cipher.iv  = random_iv
      crypt_cipher.key = to_aes_key()

      return crypt_cipher.update( cipher_text ) + crypt_cipher.final

    end


    private


    RANDOM_KEY_BYTE_LENGTH = 48

    EIGHT_BIT_INTEGER_SIZE = 256

    RANDOM_IV_BYTE_COUNT = 16

    CIPHERTEXT_BYTE_COUNT = 80

    EXPECTED_CIPHER_BIT_LENGTH = ( CIPHERTEXT_BYTE_COUNT + RANDOM_IV_BYTE_COUNT ) * 8


    def assert_non_nil_bits
      nil_err_msg = "The bit string for this key is nil."
      raise RuntimeError, nil_err_msg if @bit_string.nil?
    end


  end


end
