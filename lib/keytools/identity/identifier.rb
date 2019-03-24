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
  # type session ID within the cookies.
  #
  # == Good Identifiers Need Volumes
  #
  # IDs are not secrets - but even so, a large number of properties are required
  # to produce a high quality ID.
  #
  class Identifier


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


    # Get an identifier that is <b>always the same</b> for the parameter
    # application reference <b>regardless of the machine or shell</b> or
    # even the machine user, coming together to make the request.
    #
    # The returned identifier will consist only of alphanumeric characters
    # and one hyphen, plus it always starts and ends with an alphanumeric.
    #
    # @param app_instance_ref [String]
    #    the string reference of the application instance (or shard) that
    #    is in play and needs to be digested into a unique but not-a-secret
    #    identifier.
    #
    # @return [String]
    #    An identifier that is guaranteed to be the same whenever the
    #    same application reference is provided on any machine, using any
    #    user through any shell interface or command prompt.
    #
    #    It must be different for any other application reference.
    def self.derive_app_instance_identifier( app_instance_ref )
      return derive_identifier( app_instance_ref )
    end


    # Get an identifier that is <b>always the same</b> for the application
    # instance (with reference given in parameter) on <b>this machine</b>
    # and is always different when either/or or both the application ref
    # and machine are different.
    #
    # The returned identifier will consist of only alphanumeric characters
    # and hyphens - it will always start and end with an alphanumeric.
    #
    # This behaviour draws a fine line around the concept of machine, virtual
    # machine, <b>workstation</b> and/or <b>compute element</b>.
    #
    # <b>(aka) The AIM ID</b>
    #
    # Returned ID is aka the <b>Application Instance Machine (AIM)</b> Id.
    #
    # @param app_ref [String]
    #    the string reference of the application instance (or shard) that
    #    is being used.
    #
    # @return [String]
    #    an identifier that is guaranteed to be the same whenever the
    #    same application reference is provided on this machine.
    #
    #    it must be different on another machine even when the same
    #    application reference is provided.
    #
    #    It will also be different on this workstation if the application
    #    instance identifier provided is different.
    def self.derive_app_instance_machine_id( app_ref )
      return derive_identifier( app_ref + MachineId.derive_user_machine_id() )
    end


    # The <b>32 character</b> <b>universal identifier</b> bonds a digested
    # <b>application state identifier</b> with the <b>shell identifier</b>.
    # This method gives <b>dual double guarantees</b> to the effect that
    #
    # - a change in one, or in the other,  or in both returns a different universal id
    # - the same app state identifier in the same shell produces the same universal id
    #
    # <b>The 32 Character Universal Identifier</b>
    #
    # The universal identifier is an amalgam of two digests which can be individually
    # retrieved from other methods in this class. An example is
    #
    #       universal id => hg2x0-g3uslf-pa2bl5-09xvbd-n4wcq
    #       the shell id => g3uslf-pa2bl5-09xvbd
    #       app state id => hg2x0-n4wcq
    #
    # The 32 character universal identifier comprises of 18 session identifier
    # characters (see {derive_session_id}) <b>sandwiched between</b>
    # ten (10) digested application identifier characters, five (5) in front and
    # five (5) at the back - all segmented by four (4) hyphens.
    #
    # @param app_reference [String]
    #    the chosen plaintext application reference identifier that
    #    is the input to the digesting (hashing) algorithm.
    #
    # @param session_token [String]
    #    a triply segmented (and one liner) text token instantiated by
    #    {KeyLocal.generate_shell_key_and_token} and provided
    #    here ad verbatim.
    #
    # @return [String]
    #    a 32 character string that cannot feasibly be repeated due to the use
    #    of one way functions within its derivation. The returned identifier bonds
    #    the application state reference with the present session.
    def self.derive_universal_id( app_reference, session_token )

      shellid = derive_session_id( session_token )
      app_ref = derive_identifier( app_reference + shellid )
      chunk_1 = app_ref[ 0 .. IDENTITY_CHUNK_LENGTH ]
      chunk_3 = app_ref[ ( IDENTITY_CHUNK_LENGTH + 1 ) .. -1 ]

      return "#{chunk_1}#{shellid}#{SEGMENT_CHAR}#{chunk_3}".downcase

    end


    # The session ID generated here is a derivative of the 150 character
    # session token instantiated by {KeyLocal.generate_shell_key_and_token}
    # and provided here <b>ad verbatim</b>.
    #
    # The algorithm for deriving the session ID is as follows.
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
    # The resulting session id will look something like this
    #
    #       g3sf-pab5-9xvd
    #
    # @param session_token [String]
    #    a triply segmented (and one liner) text token instantiated by
    #    {KeyLocal.generate_shell_key_and_token} and provided here ad
    #    verbatim.
    #
    # @return [String]
    #    a 14 character string that cannot feasibly be repeated
    #    within the keyspace of even a gigantic organisation.
    #
    #    This method guarantees that the session id will always be the same when
    #    called by commands within the same shell in the same machine.
    def self.derive_session_id( session_token )

      assert_session_token_size( session_token )
      random_length_id_key = Key.from_char64( session_token.to_alphanumeric )
      a_384_bit_key = random_length_id_key.to_384_bit_key()
      a_64_char_str = a_384_bit_key.to_char64()
      base_64_chars = a_64_char_str.to_alphanumeric

      id_chars_pool = Methods.cherry_picker( ID_TRI_CHUNK_LEN, base_64_chars )
      id_hyphen_one = id_chars_pool.insert( IDENTITY_CHUNK_LENGTH, SEGMENT_CHAR )
      id_characters = id_hyphen_one.insert( ( IDENTITY_CHUNK_LENGTH * 2 + 1 ), SEGMENT_CHAR )

      err_msg = "Shell ID needs #{ID_TRI_TOTAL_LEN} not #{id_characters.length} characters."
      raise RuntimeError, err_msg unless id_characters.length == ID_TRI_TOTAL_LEN

      return id_characters.downcase

    end


    # This method returns a <b>10 character</b> digest of the parameter
    # <b>reference</b> string.
    #
    # <b>How to Derive the 10 Character Identifier</b>
    #
    # So how are the 10 characters derived from the reference provided in
    # the first parameter. The algorithm is this.
    #
    # - reverse the reference and feed it to a 256 bit digest
    # - chop away the rightmost digits so that 252 bits are left
    # - convert the one-zero bit str to 42 (YACHT64) characters
    # - remove the (on average 1.5) non-alphanumeric characters
    # - cherry pick and return <b>spread out 8 characters</b>
    #
    # @param reference [String]
    #    the plaintext reference input to the digest algorithm
    #
    # @return [String]
    #    a 10 character string that is a digest of the reference string
    #    provided in the parameter.
    def self.derive_identifier( reference )

      bitstr_256 = Key.from_binary( Digest::SHA256.digest( reference.reverse ) ).to_s
      bitstr_252 = bitstr_256[ 0 .. ( BIT_LENGTH_252 - 1 ) ]
      id_err_msg = "The ID digest needs #{BIT_LENGTH_252} not #{bitstr_252.length} chars."
      raise RuntimeError, id_err_msg unless bitstr_252.length == BIT_LENGTH_252

      id_chars_pool = Key64.from_bits( bitstr_252 ).to_alphanumeric
      undivided_str = Methods.cherry_picker( ID_TWO_CHUNK_LEN, id_chars_pool )
      id_characters = undivided_str.insert( IDENTITY_CHUNK_LENGTH, SEGMENT_CHAR )

      min_size_msg = "Id length #{id_characters.length} is not #{(ID_TWO_CHUNK_LEN + 1)} chars."
      raise RuntimeError, min_size_msg unless id_characters.length == ( ID_TWO_CHUNK_LEN + 1 )

      return id_characters.downcase

    end


    private


    ID_TWO_CHUNK_LEN = IDENTITY_CHUNK_LENGTH * 2
    ID_TRI_CHUNK_LEN = IDENTITY_CHUNK_LENGTH * 3
    ID_TRI_TOTAL_LEN = ID_TRI_CHUNK_LEN + 2

    BIT_LENGTH_252 = 252


    def self.assert_session_token_size session_token
      err_msg = "Session token has #{session_token.length} and not #{KeyLocal::SESSION_TOKEN_SIZE} chars."
      raise RuntimeError, err_msg unless session_token.length == KeyLocal::SESSION_TOKEN_SIZE
    end


  end


end
