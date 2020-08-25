#!/usr/bin/ruby

# Reopen the core ruby String class and add the below methods to it.
#
# Case Sensitivity rules for [ALL] the below methods that are
# added to the core Ruby string class.
#
# For case insensitive behaviour make sure you downcase both the
# string object and the parameter strings (or strings within
# other parameter objects, like arrays and hashes).
class String

    ## ################################################
    ## ################################################
    ## ################################################
    ## ################################################
    ## https://www.di-mgt.com.au/cryptokeys.html
    ## ################################################
    ## ################################################
    ## ################################################
    ## ################################################
    ## ################################################

  # Encrypt this string with the parameter symmetric encryption/decryption key
  # and then return the Base64 (block mode) encoded result.
  #
  # @example
  #    cipher_text  = "Hello crypt world".encrypt_block_encode "ABC123XYZ"
  #    original_txt = cipher_text.block_decode_decrypt "ABC123XYZ"
  #    (print out) original_txt # "Hello crypt world"
  #
  # @param crypt_key [String]
  #    a strong long encryption key that is used to encrypt this string before
  #    applying the Base64 block encoding.
  def encrypt_block_encode crypt_key
    encrypted_text = SafeDb::ToolBelt::Blowfish.encryptor( self, crypt_key )
    return Base64.encode64( encrypted_text )
  end



  # First apply a  base64 (block mode) decode to this string and then use the
  # parameter symmetric decryption key to decrypt the result. The output is then
  # returned within a new string.
  #
  # @example
  #    cipher_text  = "Hello crypt world".decrypt_block_encode "ABC123XYZ"
  #    original_txt = cipher_text.block_decode_decrypt "ABC123XYZ"
  #    (print out) original_txt # "Hello crypt world"
  #
  # @param crypt_key [String]
  #    a strong long decryption key that is used to decrypt this string after
  #    the  Base64 block decoding has been applied.
  def block_decode_decrypt crypt_key
    the_ciphertxt = Base64.decode64( self )
    return SafeDb::ToolBelt::Blowfish.decryptor( the_ciphertxt, crypt_key )
  end



  # Encrypt this string with the parameter symmetric encryption/decryption key
  # and then return the Base64 (url safe mode) encoded result.
  #
  # The output will be a single line and differs from the block mode with
  #
  # - underscores printed instead of forward slash characters
  # - hyphens printed instead of plus characters
  # - no (blocked) carriage return or new line characters
  #
  # Note however that sometimes one or more equals characters will be printed at
  # the end of the string by way of padding. In places like environment variables
  # that are sensitive to the equals character this can be replaced by an <b>@</b>
  # symbol.
  #
  # @example
  #    cipher_text  = "Hello @:==:@ world".encrypt_url_encode "ABC123XYZ"
  #    original_txt = cipher_text.url_decode_decrypt "ABC123XYZ"
  #    (print out) original_txt # "Hello @:==:@ world"
  #
  # @param crypt_key [String]
  #    a strong long encryption key that is used to encrypt this string before
  #    applying the Base64 ul safe encoding.
  def encrypt_url_encode crypt_key

    ## ################################################
    ## ################################################
    ## ################################################
    ## ################################################
    ## https://www.di-mgt.com.au/cryptokeys.html
    ## ################################################
    ## ################################################
    ## ################################################
    ## ################################################
    ## ################################################

    log.info(x){ "Encrypt Length => [ #{self.length} ]" }
    log.info(x){ "The Key Length => [ #{crypt_key.length} ]" }
    log.info(x){ "Encrypt String => [ #{self} ]" }
    log.info(x){ "Encryption Key => [ #{crypt_key} ]" }

    encrypted_text = SafeDb::ToolBelt::Blowfish.encryptor( self, crypt_key )

    log.info(x){ "Encrypt Result => [ #{encrypted_text} ]" }
    log.info(x){ "Encrypted Text => [ #{Base64.urlsafe_encode64(encrypted_text)} ]" }

    return Base64.urlsafe_encode64(encrypted_text)

  end



  # First apply a  base64 (url safe mode) decode to this string and then use the
  # parameter symmetric decryption key to decrypt the result. The output is then
  # returned within a new string.
  #
  # The input must will be a single line and differs from the block mode with
  #
  # - underscores printed instead of forward slash characters
  # - hyphens printed instead of plus characters
  # - no (blocked) carriage return or new line characters
  #
  # @example
  #    cipher_text  = "Hello @:==:@ world".encrypt_url_encode "ABC123XYZ"
  #    original_txt = cipher_text.url_decode_decrypt "ABC123XYZ"
  #    (print out) original_txt # "Hello @:==:@ world"
  #
  # @param crypt_key [String]
  #    a strong long decryption key that is used to decrypt this string after
  #    the Base64 url safe decoding has been applied.
  def url_decode_decrypt crypt_key
    the_ciphertxt = Base64.urlsafe_decode64( self )
    return SafeDb::ToolBelt::Blowfish.decryptor( the_ciphertxt, crypt_key )
  end




  # Overtly long file paths (eg in logs) can hamper readability so this 
  # <b>human readable filepath converter</b> counters the problem by
  # returning (only) the 2 immediate ancestors of the filepath.
  #
  # So this method returns the name of the grandparent folder then parent folder
  # and then the most significant file (or folder) name.
  #
  # When this is not possible due to the filepath being colisively near the
  # filesystem's root, it returns the parameter name.
  # 
  # @example
  #    A really long input like
  #    => /home/joe/project/degrees/math/2020
  #    is reduced to
  #    => degrees/math/2020
  #
  # @return [String] the segmented 3 most significant path name elements.
  def hr_path

    object_name   = File.basename self
    parent_folder = File.dirname  self
    parent_name   = File.basename parent_folder
    granny_folder = File.dirname  parent_folder
    granny_name   = File.basename granny_folder

    return [granny_name,parent_name,object_name].join("/")

  end


  # Return a new string matching this one with every non alpha-numeric
  # character removed. This string is left unchanged.
  #
  # Spaces, hyphens, underscores, periods are all removed. The only
  # characters left standing belong to a set of 62 and are
  #
  # - a to z
  # - A to Z
  # - 0 to 9
  #
  # @return [String]
  #    Remove any character that is not alphanumeric, a to z, A to Z
  #    and 0 to 9 and return a new string leaving this one unchanged.
  def to_alphanumeric
    return self.delete("^A-Za-z0-9")
  end


  # Find the length of this string and return a string that is the
  # concatenated union of this string and its integer length.
  # If this string is empty a string of length one ie "0" will be
  # returned.
  #
  # @return [String]
  #    Return this string with a cheeky integer tagged onto the end
  #    that represents the (pre-concat) length of the string.
  def concat_length
    return self + "#{self.length}"
  end


  # Get the text [in between] this and that delimiter [exclusively].
  # Exclusively means the returned text [does not] include either of
  # the matched delimiters (although an unmatched instance of [this]
  # delimiter may appear in the in-between text).
  #
  # ### Multiple Delimiters
  #
  # When multiple delimiters exist, the text returned is in between the
  #
  # - first occurrence of [this] delimiter AND the
  # - 1st occurrence of [that] delimiter [AFTER] the 1st delimiter
  #
  # Instances of [that] delimiter occurring before [this] are ignored.
  # The text could contain [this] delimiter instances but is guaranteed
  # not to contain a [that] delimiter.
  #
  # @throw an exception (error) will be thrown if
  #
  # - any nil (or empties) exist in the input parameters
  # - **this** delimiter does not appear in the in_string
  # - **that** delimiter does not appear after [this] one
  #
  # @param this_delimiter [String] begin delimiter (not included in returned string)
  # @param that_delimiter [String] end delimiter (not included in returned string)
  #
  # @return [String] the text in between (excluding) the two parameter delimiters
  def in_between this_delimiter, that_delimiter

    raise ArgumentError, "This string is NIL or empty." if self.nil? || self.empty?
    raise ArgumentError, "Begin delimiter is NIL or empty." if this_delimiter.nil? || this_delimiter.empty?
    raise ArgumentError, "End delimiter is NIL or empty." if that_delimiter.nil? || that_delimiter.empty?
    
    scanner_1 = ::StringScanner.new self
    scanner_1.scan_until /#{this_delimiter}/
    scanner_2 = ::StringScanner.new scanner_1.post_match
    scanner_2.scan_until /#{that_delimiter}/

    in_between_text = scanner_2.pre_match.strip
    return in_between_text

  end


  # To hex converts this string to hexadecimal form and returns
  # the result leaving this string unchanged.
  # @return [String] hexadecimal representation of this string
  def to_hex

    return self.unpack("H*").first

  end


  # From hex converts this (assumed) hexadecimal string back into
  # its normal string form and returns the result leaving this string
  # unchanged.
  # @return [String] string that matches the hexadecimal representation
  def from_hex

    return [self].pack("H*")

  end


  # Flatten (lower) a camel cased string and add periods to
  # denote separation where the capital letters used to be.
  #
  # Example behaviour is illustrated
  #
  # - in  => ObjectOriented
  # - out => object.oriented
  #
  # Even when a capital letter does not lead lowercase characters
  # the behaviour should resemble this.
  #
  # - in  => SuperX
  # - out => super.x
  #
  #
  # And if every letter is uppercase, each one represents its
  # own section like this.
  #
  # - in  => BEAST
  # - out => b.e.a.s.t
  #
  # == Flatten Class Names
  #
  # If the string comes in as a class name we can expect it to
  # contain colons like the below examples.
  #    This::That
  #    ::That
  #    This::That::TheOther
  #
  # So we find the last index of a colon and then continue as per
  # the above with flattening the string.
  #
  # @return [String] a flatten (period separated) version of this camel cased string
  def do_flatten

    to_flatten_str = self

    last_colon_index = to_flatten_str.rindex ":"
    ends_with_colon = to_flatten_str[-1].eql? ":"
    unless ( last_colon_index.nil? || ends_with_colon )
      to_flatten_str = to_flatten_str[ (last_colon_index+1) .. -1 ]
    end

    snapped_str = ""
    to_flatten_str.each_char do |this_char|
      is_lower = "#{this_char}".is_all_lowercase?
      snapped_str += "." unless is_lower || snapped_str.empty?
      snapped_str += this_char.downcase
    end

    return snapped_str

  end



  # Return true if every character in this string is lowercase.
  # Note that if this string is empty this method returns true.
  #
  # @return true if every alpha character in this string is lowercase
  def is_all_lowercase?
    return self.downcase.eql? self
  end



  # Flatten (lower) a camel cased string and add periods to
  # denote separation where the capital letters used to be.
  # The inverse operation to [ do_flatten ] which  resurrects
  # this (expected) period separated string changing it back
  # to a camel (mountain) cased string.
  #
  # Example behaviour is illustrated
  #
  # - in  => object.oriented
  # - out => ObjectOriented
  #
  # Even when a single character exists to the right of the period
  # the behaviour should resemble this.
  #
  # - in  => super.x
  # - out => SuperX
  #
  #
  # And if every letter is period separated
  #
  # - in  => b.e.a.s.t
  # - out => BEAST
  #
  # @return [String] camel cased version of this flattened (period separated) string
  def un_flatten

    segment_array = self.strip.split "."
    resurrected_arr = Array.new

    segment_array.each do |seg_word|
      resurrected_arr.push seg_word.capitalize
    end

    undone_str = resurrected_arr.join
    log.info(x){ "unflattening => [#{self}] and resurrecting to => [#{undone_str}]" }

    return undone_str

  end



  # --
  # Return true if the [little string] within this
  # string object is both
  # --
  #  a] topped by the parameter prefix AND
  #  b] tailed by the parameter postfix
  # --
  # -----------------------------------------
  # In the below example [true] is returned
  # -----------------------------------------
  # --
  #   This [String] => "Hey [<-secrets->] are juicy."
  #   little string => "secrets"
  #   topped string => "[<-"
  #   tailed string => "->]"
  # --
  # Why true? Because the little string "secret" is
  # (wrapped) topped by "[<-" and tailed by "->]"
  # --
  # -----------------------------------------
  # Assumptions | Constraints | Boundaries
  # -----------------------------------------
  # --
  #   - all matches are [case sensitive]
  #   - this string must contain little_str
  #   - one strike and its true
  #       (if little string appears more than once)
  #       so => "all secrets, most [<-secrets->] r juicy"
  #          => true as long as (at least) one is wrapped
  # --
  # --
  def has_wrapped? little_str, prefix, postfix

    return self.include?( prefix + little_str + postfix )

  end

  
  # Sandwich the first occurrence of a substring in
  # this string with the specified pre and postfix.
  #
  # This string contains the little string and an
  # IN-PLACE change is performed with the first
  # occurrence of the little string being prefixed
  # and postfixed with the 2 parameter strings.
  #
  # Example of sandwiching [wrapping]
  #
  # -  [String]  => "Hey secrets are juicy."
  # -  [To_Wrap] => "secrets"
  # -  [Prefix]  => "[<-"
  # -  [Postfix] => "->]"
  #
  #   [String]  => "Hey [<-secrets->] are juicy."
  #
  # This string IS changed in place.
  def sandwich_substr to_wrap_str, prefix, postfix

    occurs_index = self.downcase.index to_wrap_str.downcase
    self.insert occurs_index, prefix
    shifted_index = occurs_index + prefix.length + to_wrap_str.length
    self.insert shifted_index, postfix

  end

  
  # The parameter is a list of character sequences and TRUE is returned
  # if EVERY ONE of the character sequences is always found nestled somewhere
  # within this string. The matching is case-sensitive.
  #
  # The parameter array can be [empty] but not nil. And the harboured
  # character sequences can neither be nil nor empty.
  #
  # @param word_array [Array] array of string words for the inclusivity test
  #
  # @return [Boolean] true if EVERY ONE of the char sequences appear somewhere in this string
  def includes_all? word_array

    raise ArgumentError, "This string is NIL" if self.nil?
    raise ArgumentError, "The parameter word array is NIL" if word_array.nil?

    word_array.each do |word|

      raise ArgumentError, "The word array #{word_array} contains a nil value." if word.nil?
      return false unless self.include? word

    end

    return true

  end


  # The parameter is a list of character sequences and TRUE is returned
  # if any one of the character sequences can be found nestled somewhere
  # within this string. The matching is case-sensitive.
  #
  # The parameter array can be [empty] but not nil. And the harboured
  # character sequences can neither be nil nor empty.
  #
  # @param word_array [Array] array of string words for the inclusivity test
  #
  # @return [Boolean] true if string includes ANY one of the character sequences in array
  def includes_any? word_array

    raise ArgumentError, "This string is NIL" if self.nil?
    raise ArgumentError, "The parameter word array is NIL" if word_array.nil?

    word_array.each do |word|

      raise ArgumentError, "The word array #{word_array} contains a nil value." if word.nil?
      return true if self.include? word

    end

    return false

  end


  # --
  # Encrypt this string with the parameter encryption/decryption key
  # and return the encrypted text as a new string.
  # --
  #  decrypt_key  => the key that will decrypt the output string
  # --
  # --
  def encrypt decrypt_key

## ----> Write a RE-CRYPT method that goes through a folder - decrypting and recrypting
## ----> Write a RE-CRYPT method that goes through a folder - decrypting and recrypting
## ----> Write a RE-CRYPT method that goes through a folder - decrypting and recrypting
## ----> Write a RE-CRYPT method that goes through a folder - decrypting and recrypting

###### ON Linux improve by changing to OpenSSL::Cipher.new('DES-EDE3-CBC').encrypt
###### ON Linux improve by changing to Digest::SHA2.hexdigest decrypt_key
###### ON Linux improve by changing to OpenSSL::Cipher.new('DES-EDE3-CBC').encrypt
###### ON Linux improve by changing to Digest::SHA2.hexdigest decrypt_key
###### ON Linux improve by changing to OpenSSL::Cipher.new('DES-EDE3-CBC').encrypt
###### ON Linux improve by changing to Digest::SHA2.hexdigest decrypt_key
###### ON Linux improve by changing to OpenSSL::Cipher.new('DES-EDE3-CBC').encrypt
###### ON Linux improve by changing to Digest::SHA2.hexdigest decrypt_key

    cipher = OpenSSL::Cipher::Cipher.new('DES-EDE3-CBC').encrypt
    cipher.key = Digest::SHA1.hexdigest decrypt_key
    crypted = cipher.update(self) + cipher.final
    encrypted_text = crypted.unpack('H*')[0].upcase

    return encrypted_text

  end


  # --
  # Decrypt this string with the parameter encryption/decryption key
  # and return the decrypted text as a new string.
  # --
  #  encrypt_key  => the key the input string was encrypted with
  # --
  # --
  def decrypt encrypt_key

## ----> Write a RE-CRYPT method that goes through a folder - decrypting and recrypting
## ----> Write a RE-CRYPT method that goes through a folder - decrypting and recrypting
## ----> Write a RE-CRYPT method that goes through a folder - decrypting and recrypting
## ----> Write a RE-CRYPT method that goes through a folder - decrypting and recrypting

###### ON Linux improve by changing to OpenSSL::Cipher.new('DES-EDE3-CBC').encrypt
###### ON Linux improve by changing to Digest::SHA2.hexdigest decrypt_key
###### ON Linux improve by changing to OpenSSL::Cipher.new('DES-EDE3-CBC').encrypt
###### ON Linux improve by changing to Digest::SHA2.hexdigest decrypt_key
###### ON Linux improve by changing to OpenSSL::Cipher.new('DES-EDE3-CBC').encrypt
###### ON Linux improve by changing to Digest::SHA2.hexdigest decrypt_key

    cipher = OpenSSL::Cipher::Cipher.new('DES-EDE3-CBC').decrypt
    cipher.key = Digest::SHA1.hexdigest encrypt_key
    uncrypted = [self].pack("H*").unpack("C*").pack("c*")
    decrypted_text = cipher.update(uncrypted) + cipher.final

    return decrypted_text

  end


  # Log the string which is expected to be delineated.
  #   If the string originated from a file it will be logged
  #   line by line. If no line delineation the string will be
  #   dumped just as a blob.
  #
  # The INFO log level is used to log the lines - if this is not
  #   appropriate create a (level) parameterized log lines method.
  def log_lines
    log_info()
  end


  # Log at the INFO level the string which is expected to be
  # delineated. If the string originated from a file it will
  # be logged line by line.
  #
  # If no line delineation the string will be dumped just as
  # a blob.
  def log_info

    self.each_line do |line|
      clean_line = line.chomp.gsub("\\n","")
      log.info(x) { line } if clean_line.length > 0
    end

  end


  # Log at the INFO level the string which is expected to be
  # delineated. If the string originated from a file it will
  # be logged line by line.
  #
  # If no line delineation the string will be dumped just as
  # a blob.
  def log_debug

    self.each_line do |line|
      clean_line = line.chomp.gsub("\\n","")
      log.debug(x) { line } if clean_line.length > 0
    end

  end


end
