#!/usr/bin/ruby
# coding: utf-8

module SafeDb

  module ToolBelt

  # CryptIO concentrates on injecting and ingesting crypt properties into and
  # out of a key/value dictionary as well as injecting and ingesting cryptographic
  # materials into and out of text files.
  #
  # == Cryptographic Properties
  #
  # A crypt properties dictionary acts as <b>output from every encryption event</b>
  # and <b>input to every decryption event</b>. The most common properties include
  #
  # - the symmetric key used for the encryption and decryption
  # - the iv (initialization vector) that adds another dimension of strength
  # - authorization data that thwarts switch attacks by tying context to content
  # - the cipher algorithm, its implementation and its encryption strength
  # - the various glue strings that allow related ciphertext to occupy a file
  #
  # == Why Pad?
  #
  # Many ciphers (like Blowfish) constrains plain text lengths to multiples
  # of 8 (or 16) and a common <b>right pad with spaces</b> strategy is employed
  # as a workaround. safe does it diferently.
  #
  # == Why isn't Space Padding Used?
  #
  # If safe padded plaintext (ending in one or more spaces) with
  # spaces, the decrypt phase (after right stripping spaces) would return
  # plain text string <b>shorter than the original</b>.
  #
  # == Why Unusual Padding and Separators
  #
  # Why does safe employ unusual strings for padding and separation.
  #
  # The separator string must be unusual to make it unlikely for it to occur in any
  # of the map's key value pairs nor indeed the chunk of text being glued. Were
  # this to happen, the separate and reconstitute phase may not accurately return
  # the same two entities we are employed to unite.
  #
  # == So How is Padding Done?
  #
  # Instead of single space padding - safe uses an unlikely 7 character
  # padder which is repeated until the multiple is reached.
  #
  # <tt><-|@|-></tt>
  #
  # == So How is Padding Done?
  #
  # The <b>padder length must be a prime number</b> or infinite loops could occur.
  #
  #    If the padder string is likely to occur in the plain text, another
  #    padder (or strategy) should and could be employed.
  #
  class CryptIO


    # The safe text padder. See the class description for an analysis
    # of the use of this type of padder.
    TEXT_PADDER = "<-|@|->"

    # An unusual string that glues together an encryption dictionary and
    # a chunk of base64 encoded and encrypted ciphertext.
    # The string must be unusual enough to ensure it does not occur within
    # the dictionary metadata keys or values.
    INNER_GLUE_STRING = "\n<-|@| <  || safe inner crypt material axis ||  > |@|->\n\n"

    # An unusual string that glues together the asymmetrically encrypted outer
    # encryption key  with the outer crypted text.
    OUTER_GLUE_STRING = "\n<-|@| <  || safe outer crypt material axis ||  > |@|->\n\n"

    # Text header for key-value pairs hash map that will be serialized.
    DICT_HEADER_NAME = "crypt.properties"

    # Name for the class of cipher employed.
    DICT_CIPHER_NAME = "cipher.class"

    # Name for the {Base64} encoded symmetric (lock/unlock) crypt key.
    DICT_CRYPT_KEY = "encryption.key"

    # Dictionary name for the encryption iv (initialization vector)
    DICT_CRYPT_IV = "encryption.iv"

    # Dictionary name for the Base64 (urlsafe) encoded plaintext digest.
    DICT_TEXT_DIGEST = "plaintext.digest"


    # Serialize and then unify a hash map and a textual chunk using
    # a known but unusual separator string in a manner that protects
    # content integrity during the serialize / deserialize process.
    #
    # This crypt serialization uses a specific "inner glue" as the
    # string that separates the serialized key/value dictionary and
    # the encoded textual block.
    #
    # @param hash_map [String]
    #    this hash (dictionary) will be serialized into INI formatted text
    #    using behaviour from {Hash} and {IniFile}.
    #
    # @param text_chunk [String]
    #    the usually Base64 encrypted textual block to be glued at the
    #    bottom of the returned block.
    #
    # @return [String] serialized and glued together result of map plus text
    #
    # @raise [ArgumentError]
    #    if the dictionary hash_map is either nil or empty.
    def self.inner_crypt_serialize hash_map, text_chunk

      nil_or_empty_hash = hash_map.nil? || hash_map.empty?
      raise ArgumentError, "Cannot serialize nil or empty properties." if nil_or_empty_hash
      ini_map = IniFile.new
      ini_map[ DICT_HEADER_NAME ] = hash_map
      return ini_map.to_s + INNER_GLUE_STRING + text_chunk

    end


    # Deserialize an safe formatted text which contains an
    # encryption properties dictionary (serialized in INI format)
    # and a Base64 encoded crypt block which is the subject of the
    # encryption dictionary.
    #
    # The crypt serialization used a specific "inner glue" as the
    # string that separates the serialized key/value dictionary and
    # the encoded textual block. We now employ this glue to split
    # the serialized dictionary from the textual block.
    #
    # @param hash_map [String]
    #    send an instantiated hash (dictionary) which will be populated
    #    by this deserialize operation. The dictionary propeties can
    #    then be used to decrypt the returned ciphertext.
    #
    # @param text_block [String]
    #    the first of a two-part amalgamation is a hash (dictionary) in
    #    INI serialized form and the second part is a Base64 encrypted
    #    textual block.
    #
    #    The deserialized key/value pairs will be stuffed into the
    #    non nil (usually empty) hash map in the first parameter and
    #    the block (in the 2nd part) will be Base64 decoded and
    #    returned by this method.
    #
    # @return [String]
    #    The encoded block in the 2nd part of the 2nd parameter will be
    #    Base64 decoded and returned.
    #
    # @raise [ArgumentError]
    #    if the dictionary hash_map is either nil or empty. Also if
    #    the inner glue tying the two parts together is missing an
    #    {ArgumentError} will be thrown.
    def self.inner_crypt_deserialize hash_map, text_block

      raise ArgumentError, "Cannot populate a nil hash map." if hash_map.nil?
      assert_contains_glue text_block, INNER_GLUE_STRING

      serialized_map = text_block.split(INNER_GLUE_STRING).first.strip
      encoded64_text = text_block.split(INNER_GLUE_STRING).last.strip
      ini_props_hash = IniFile.new( :content => serialized_map )
      encrypt_values = ini_props_hash[DICT_HEADER_NAME]

      hash_map.merge!( encrypt_values )
      return Base64.decode64( encoded64_text )

    end


    # Using an outer divider (glue) - attach the asymmetrically encrypted outer
    # encryption key  with the outer encrypted text.
    #
    # @param crypt_material_x [String] asymmetrically encrypted (encoded) outer encryption key
    # @param crypt_material_y [String] symmetrically encrypted inner metadata and payload crypt
    #
    # @return [String] concatenated result of the two crypt materials and divider string
    def self.outer_crypt_serialize crypt_material_x, crypt_material_y
      return crypt_material_x + OUTER_GLUE_STRING + crypt_material_y
    end


    # Given two blocks of text that were bounded together by the
    # {self.outer_crypt_serialize} method we must return either the
    # first block (true) or the second (false).
    #
    # @param crypt_material [String]
    #    large block of text in two parts that is divided by the
    #    outer glue string.
    #
    # @param top_block [Boolean]
    #    if true the top (of the two) blocks will be returned
    #    otherwise the bottom block is returned.
    #
    # @return [String] either the first or second block of text
    #
    # @raise [ArgumentError]
    #    If the outer glue string tying the two parts together is
    #    missing an {ArgumentError} will be thrown.
    def self.outer_crypt_deserialize os_material, top_block

      assert_contains_glue os_material, OUTER_GLUE_STRING
      return os_material.split(OUTER_GLUE_STRING).first.strip if top_block
      return os_material.split(OUTER_GLUE_STRING).last.strip

    end


    private

    def self.assert_contains_glue os_crypted_block, glue_string

      no_glue_msg = "\nGlue string not in safe cipher block.\n#{glue_string}\n"
      raise ArgumentError, no_glue_msg unless os_crypted_block.include? glue_string

    end


  end


  end


end
