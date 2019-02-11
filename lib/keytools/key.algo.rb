#!/usr/bin/ruby
# coding: utf-8

module SafeDb

  # Algorithms that are quality catalysts in the derivation and entropy spread
  # of keys, identifiers and base64 character numbers.
  class KeyAlgo


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


  end


end
