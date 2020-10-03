#!/usr/bin/ruby
# coding: utf-8


module SafeDb


  # This class derives <b>non secret but unique identifiers</b> based on different
  # combinations of the <b>application, shell and machine (compute element)</b>
  # references.
  #
  # == Identifier Are Not Secrets
  #
  # <b>And their starting values are retrievable</b>
  #
  # Note that the principle and practise of <b>identifiers is not about keeping secrets</b>.
  # An identifier can easily give up its starting value/s if and when brute force is
  # applied. The properties of a good iidentifier (ID) are
  #
  # - non repeatability (also known as uniqueness)
  # - non predictability (of the next identifier)
  # - containing alphanumerics (for file/folder/url names)
  # - human readable (hence hyphens and separators)
  # - non offensive (no swear words popping out)
  #
  # == Story | Identifiers Speak Volumes
  #
  # I told a friend what the turnover of his company was and how many clients he had.
  # He was shocked and wanted to know how I had gleened this information.
  #
  # The invoices he sent me (a year apart). Both his invoice IDs (identifiers) and his
  # user IDs where integers that counted up. So I could determine how many new clients
  # he had in the past year, how many clients he had when I got the invoice, and I
  # determined the turnover by guesstimating the average invoice amount.
  #
  # Many successful website attacks are owed to a predictable customer ID or a counter
  # type branch ID within the cookies.
  #
  # == Good Identifiers Need Volumes
  #
  # IDs are not secrets - but even so, a large number of properties are required
  # to produce a high quality ID.
  #
  class Identifier

    # The ergonomic list of 24 characters highly suited for use within
    # human readable and likable identifier strings.
    ERGONOMIC_LIST = [
      "b", "c", "d", "e", "h", "k",
      "m", "n", "r", "t", "v", "w",
      "x", "z", "0", "1", "2", "3",
      "4", "5", "6", "7", "8", "9"
    ]


    # The identity chunk length is set at four (4) which means each of the
    # fabricated identifiers comprises of four character segments divided by
    # hyphens. Only the <b>62 alpha-numerics ( a-z, A-Z and 0-9 )</b> will
    # appear within identifiers - which maintains simplicity and provides an
    # opportunity to re-iterate that <b>identifiers</b> are designed to be
    # <b>unpredictable</b>, but <b>not secret</b>.
    IDENTITY_CHUNK_LENGTH = 4


    # A hyphen is the chosen character for dividing the identifier strings
    # into chunks of four (4) as per the {IDENTITY_CHUNK_LENGTH} constant.
    SEGMENT_CHAR = "-"

    ID_TRI_CHUNK_LEN = IDENTITY_CHUNK_LENGTH * 3
    ID_TRI_TOTAL_LEN = ID_TRI_CHUNK_LEN + 2


    # Get an ergonomic identifier that is a <b>one to one mapping</b> for the
    # parameter string. In as far as is possible, two different input strings
    # should never produce the same output identifier, nor should one input
    # string be ambiguously mapped to two output identifiers.
    #
    # This algorithm must be brute force tested to verify the above assertions.
    #
    # <tt>The 24 Ergonomic Characters</tt>
    #
    # The returned identifier is ergonomic in that its characters come from a
    # pool of 24 of the most suitable ID characters - pleasant to see, easy to
    # digest and simple to convey.
    #
    # <b>How to Derive the Ergonomic Identifier</b>
    #
    # We pass the parameter string through a SHA512 digest algorithm and truncate
    # the final 2 binary digits because 510 is a multiple of six and perfect for
    # the transformation to a Base64 string.
    #
    # The Base64 transform gives us 85 characters from which we remove any non
    # alphanumerics. We repeat all the above again with the parameter reversed
    # and append the two resultants together.
    #
    # This harvests roughly 160 characters from which we downcase and walk
    # through picking out a selection of just 24 ergonomic characters.
    #
    # @param source [String]
    #    the source string whose characters we digest and filter to produce a
    #    high quality, pleasing ergonomic identifier
    #
    #    Before processing any leading or trailing whitespace is removed from
    #    the input string.
    #
    # @param id_length [Numeric]
    #    the number of identifier characters to return. This parameter must be
    #    even and divisible by 3 in case it needs to be split (for readability)
    #    into two or three segments.
    #
    #    There is a logical maximum above which it is foolish to venture. The
    #    max is about two-thirds of a sixth of a thousand characters which is
    #    slightly over 100.
    #
    # @return [String]
    #    An identifier that is guaranteed to be the same whenever the same
    #    input string is provided.
    #
    #    This algorithms quality is predicated on the premise that two different
    #    input strings should never produce the same output, nor should one input
    #    string be ambiguously mapped to two output identifiers.
    #
    #    The default behaviour is to split the output identifier into 2 segments
    #    separated by a hyphen.
    def self.derive_ergo_identifier( source, id_length )

      abort "The source string cannot be nil or empty." if source.nil?() or source.empty?()
      abort "The source cannot consist only of whitespace." if source.strip().empty?()
      abort "The ID length must not be less than 2." unless id_length > 1
      abort "The ID length must be a multiple of 2." unless id_length % 2 == 0
      abort "Prudent identifiers do not exceed 80 characters." unless id_length < 80

      digested_bits = Key.from_binary( Digest::SHA512.digest( source.strip() ) ).to_s +
                      Key.from_binary( Digest::SHA512.digest( source.strip().reverse() ) ).to_s

      digest_string = Key64.from_bits( digested_bits[ 0 .. ( 1020 - 1 ) ] ).to_alphanumeric
      filtered_digest = ergonomic_filter( digest_string, id_length )
      return filtered_digest.insert( id_length/2, SEGMENT_CHAR )

    end


    # This ergonomic filter produces a pleasing readable identifier that is
    # down cased and does not contain characters like o, l, s, a, i, or u.
    #
    # Swear words can pop up so most vowels are removed to save your blushes.
    #
    # @param raw_digest [String]
    #    the source string whose characters we filter in order to produce a
    #    high quality, pleasing ergonomic identifier
    #
    # @param id_length [Numeric]
    #    the number of identifier characters to return. This parameter must be
    #    even and divisible by 3 in case it needs to be split (for readability)
    #    into two or three segments.
    #
    # @return [String]
    #    The filtered identifier containing only the 24 desirable characters.
    #
    def self.ergonomic_filter( raw_digest, id_length )

      id_characters = ""
      raw_digest.downcase().each_char() do | digest_char |
        id_characters.concat( digest_char ) if ERGONOMIC_LIST.include?( digest_char )
        break if id_characters.length() == id_length
      end

      return id_characters

    end

=begin
    require_relative "../keys/key.64"
    require_relative "../keys/key"
    input1 = "apollo@akora"
    output1 = Identifier.derive_ergonomic_identifier( input1, 90 )
    puts "Input #{input1} produced output #{output1}"
=end

    # This method produces a soft random identifier by grabbing a secure
    # random binary string, transforming it to base64, removing any and all
    # hyphens and underscores, downcasing the result and finally truncating
    # it to produce a random identifier of the desired length.
    #
    # Do not use this method to produce passwords or secrets because it
    # provides IDs from a pool of only 36 characters with a fixed length so
    # can be brute forced with ease. Only use it for producing identifiers.
    #
    # @param id_length [Number]
    #    the length of the returned identifier. This value should not exceed
    #    50 characters as the source pool is a good size - but is by no means
    #    infinitely long.
    def self.get_random_identifier( id_length )

      require 'securerandom'
      random_ref = SecureRandom.urlsafe_base64( id_length ).delete("-_").downcase
      return random_ref[ 0 .. ( id_length - 1 ) ]

    end


    # The branch ID generated here is a derivative of the 150 character
    # shell token.
    #
    # The algorithm for deriving the branch ID is as follows.
    #
    # - convert the 150 characters to an alphanumeric string
    # - convert the result to a bit string and then to a key
    # - put the key's binary form through a 384 bit digest
    # - convert the digest's output to 64 YACHT64 characters
    # - remove the (on average 2) non-alphanumeric characters
    # - cherry pick a spread out 12 characters from the pool
    # - hiphenate the character positions five (5) and ten (10)
    # - ensure the length of the resultant ID is fourteen (14)
    #
    # The resulting branch id will look something like this
    #
    #       g3sf-pab5-9xvd
    #
    # @param shell_token [String]
    #    a triply segmented (and one liner) text token
    #
    # @return [String]
    #    a 14 character string that cannot feasibly be repeated
    #    within the keyspace of even a gigantic organisation.
    #
    #    This method guarantees that the branch id will always be the same when
    #    called by commands within the same shell in the same machine.
    def self.derive_branch_id( shell_token )

      assert_shell_token_size( shell_token )
      random_length_id_key = Key.from_char64( shell_token.to_alphanumeric )
      a_384_bit_key = random_length_id_key.to_384_bit_key()
      a_64_char_str = a_384_bit_key.to_char64()
      base_64_chars = a_64_char_str.to_alphanumeric

      id_chars_pool = cherry_picker( ID_TRI_CHUNK_LEN, base_64_chars )
      id_hyphen_one = id_chars_pool.insert( IDENTITY_CHUNK_LENGTH, SEGMENT_CHAR )
      id_characters = id_hyphen_one.insert( ( IDENTITY_CHUNK_LENGTH * 2 + 1 ), SEGMENT_CHAR )

      err_msg = "Shell ID needs #{ID_TRI_TOTAL_LEN} not #{id_characters.length} characters."
      raise RuntimeError, err_msg unless id_characters.length == ID_TRI_TOTAL_LEN

      return id_characters.downcase

    end


    # Cherry pick a given number of characters from the character pool
    # so that a good spread is achieved. This picker is the anti-pattern
    # of just axing the first 5 characters from a 100 character string
    # essentially wasting over 90% of the available entropy.
    #
    # This is the <b>algorithem to cherry pick</b> a spread of characters
    # from the pool in the second parameter.
    #
    # - if the character pool length is a multiple of num_chars all is good otherwise
    # - constrict to the <b>highest multiple of the pick size below</b> the pool length
    # - divide that number by num_chars to get the first offset and character spacing
    # - if spacing is 3, the first character is the 3rd, the second the 6th and so on
    # - then return the cherry picked characters
    #
    # @param pick_size [FixNum] the number of characters to cherry pick
    # @param char_pool [String] a pool of characters to cherry pick from
    # @return [String]
    #    a string whose length is the one indicated by the first parameter
    #    and whose characters contain a predictable, repeatable spread from
    #    the character pool parameter
    def self.cherry_picker( pick_size, char_pool )

      hmb_limit = highest_multiple_below( pick_size, char_pool.length )
      jump_size = hmb_limit / pick_size
      read_point = jump_size
      picked_chars = ""
      loop do 
        picked_chars += char_pool[ read_point - 1 ]
        read_point += jump_size
        break if read_point > hmb_limit
      end
      
      err_msg = "Expected cherry pick size to be #{pick_size} but it was #{picked_chars.length}."
      raise RuntimeError, err_msg unless picked_chars.length == pick_size

      return picked_chars

    end
    

    # Affectionately known as <b>a hmb</b>, this method returns the
    # <b>highest multiple</b> of the first parameter that is below
    # <b>(either less than or equal to)</b> the second parameter.
    #
    #      - -------- - ------- - ----------------- -
    #      |  Small   |   Big   | Highest Multiple  |
    #      |  Number  |  Number |  Below Big Num    |
    #      | -------- - ------- - ----------------- |
    #      |    5     |   25    |      25           |
    #      |    3     |   20    |      18           |
    #      |    8     |   63    |      56           |
    #      |    1     |    1    |       1           |
    #      |    26    |   28    |      26           |
    #      |    1     |    7    |       7           |
    #      |    16    |   16    |      16           |
    #      | -------- - ------- - ----------------- |
    #      |    10    |    8    |     ERROR         |
    #      |   -4     |   17    |     ERROR         |
    #      |    4     |  -17    |     ERROR         |
    #      |    0     |   32    |     ERROR         |
    #      |    29    |   0     |     ERROR         |
    #      |   -4     |   0     |     ERROR         |
    #      | -------- - ------- - ----------------- |
    #      - -------- - ------- - ----------------- -
    #
    # Zeroes and negative numbers cannot be entertained, nor can the
    # small number be larger than the big one.
    #
    # @param small_num [FixNum]
    #    the highest multiple of this number below the one in the
    #    next parameter is what will be returned.
    #
    # @param big_num [FixNum]
    #    returns either this number or the nearest below it that is
    #    a multiple of the number in the first parameter.
    #
    # @raise [ArgumentError]
    #    if the first parameter is greater than the second
    #    if either or both parameters are zero or negative
    def self.highest_multiple_below small_num, big_num

      arg_issue = (small_num > big_num) || small_num < 1 || big_num < 1
      err_msg = "Invalid args #{small_num} and #{big_num} to HMB function."
      raise ArgumentError, err_msg if arg_issue

      for index in 0 .. ( big_num - 1 )
        invex = big_num - index # an [invex] is an inverted index
        return invex if invex % small_num == 0
      end
      
      raise ArgumentError, "Could not find a multiple of #{small_num} lower than #{big_num}"

    end


    private


    def self.assert_shell_token_size shell_token
      err_msg = "shell token has #{shell_token.length} and not #{KeyDerivation::SHELL_TOKEN_SIZE} chars."
      raise RuntimeError, err_msg unless shell_token.length == KeyDerivation::SHELL_TOKEN_SIZE
    end


  end


end
