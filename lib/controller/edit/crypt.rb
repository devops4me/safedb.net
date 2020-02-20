#!/usr/bin/ruby
	
module SafeDb

  # The <b>generate use case</b> generates a random string credential that abides by
  # the laws set out by configured and/or default parameter properties. These properties
  # include the character superset to which all credential characters belong, the median
  # length of the credential and the (give or take) span denoting the shortest and
  # longest possible credentials.
  #
  # If the parameter line already exists in the verse, it is backed up by appending
  # it with a timestamp to prevent overwriting (and losing) the old value forever. This
  # no clobber behaviour can be switched off by passing the --overwrite flag.
  class Generate < EditVerse

    # This is the name of the key the generated randomized string will be
    # stored against within the current opened chapter and verse.
    attr_writer :line

    # A default median length of 14 characters with a give or take
    # span of two means that the resulting password length could be
    # one of either 12, 13, 14, 15 or 16 characters.
    MEDIAN_LENGTH = 14

    # If a median length of 15 is required with give or take set
    # at 3 - the resulting password length could be anything from
    # a minimum of 12 (15 - 3) to a maximum of 18 (15 + 3).
    GIVE_OR_TAKE_SIZE = 2

    # The length range typifies the set of possible credential lengths
    # that can be produced by this class. The lower bound is the median
    # length less give or take, the upper bound is the median length
    # plus the give or take size.
    LENGTH_RANGE = (MEDIAN_LENGTH - GIVE_OR_TAKE_SIZE) .. ( MEDIAN_LENGTH + GIVE_OR_TAKE_SIZE )

    # The super strong non alpha-numeric character set has a large
    # set of characters configured for the most secure credentials
    # protecting security concious application states.
    STRONG_CHARACTERS = "?@=$~%/+^.,][\{\}\<\>\&\(\)_\-"

    # The widely accepted non alpha-numeric character set contains
    # these characters
    #
    # - an @ sign
    # - a percent sign
    # - plus sign
    # - a period
    # - a comma
    # - an (open) square bracket
    # - a (close) square bracket
    # - an underscore
    # - a hyphen
    WIDELY_ACCEPTED_CHARS = "@%+.,][_\-"

    # This is the command used to generate the credentials stream.
    GENERATE_CMD = "head /dev/urandom | tr -dc A-Za-z0-9#{WIDELY_ACCEPTED_CHARS} | head -c 258"

    # The <b>generate use case</b> generates random strings that abide by a configured
    # median length, span size, and a configured superset of characters that the generated
    # credentials characters will be a subset of.
    def edit_verse()

      credential_length = Random.new().rand( LENGTH_RANGE )
      credential_stream = %x[ #{GENERATE_CMD} ]
      credential_string = credential_stream.chomp()[ 0 .. ( credential_length - 1 ) ]
      
      @verse.store( "#{@line}-#{TimeStamp.yyjjj_hhmm_sst()}", @verse[ @line ] ) if @verse.has_key?( @line )
      @verse.store( @line, credential_string )

    end


  end


end
