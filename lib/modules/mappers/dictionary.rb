#!/usr/bin/ruby
# coding: utf-8

module OpenKey

  require 'inifile'

  # An OpenSession dictionary is a <b>2D (two dimensional) hash</b> data
  # structure backed by an encrypted file.
  #
  # It supports operations to <b>read from</b> and <b>write to</b> a known
  # filepath and given the correct symmetric encryption key it will
  #
  # - decrypt <b>after reading from</b> the file and
  # - encrypt <b>before writing to</b> the file
  #
  # This dictionary extends {Hash} in order to deliver on its core key value
  # storage and retrieve use cases. Extend this dictionary and provide
  # context specific methods through constants to read and write context
  # specific data.
  #
  # == The <em>Current</em> Dictionary Section
  #
  # This Dictionary is <b>two-dimensional</b> so all key-value pairs are stored
  # under the auspices of a section.
  #
  # The Dictionary can track the <b>current section</b> for you and all data
  # exchanges can occur in lieu of a single section if you so wish by using
  # the provided {put} and {get} methods.
  #
  # To employ section management functionality you should pass in a current
  # <b>section id</b> when creating the dictionary.
  #
  # @example
  #    To use the dictionary in the raw (unextended) format you create
  #    write and read it like this.
  #
  #    ----------------------------------------------------------------------
  #
  #    my_dictionary = Dictionary.create( "/path/to/backing/file" )
  #
  #    my_dictionary["user23"] = {}
  #    my_dictionary["user23"]["Name"] = "Joe Bloggs"
  #    my_dictionary["user23"]["Email"] = "joebloggs@example.com"
  #    my_dictionary["user23"]["Phone"] = "+44 07342 800080"
  #
  #    my_dictionary.write( "crypt-key-1234-wxyz" )
  #
  #    ----------------------------------------------------------------------
  #
  #    my_dictionary = Dictionary.create( "/path/to/backing/file", "crypt-key-1234-wxyz" )
  #    puts my_dictionary.has_key? "user23"   # => true
  #    puts my_dictionary["user23"].length    # => 3
  #    puts my_dictionary["user23"]["Email"]  # => "joebloggs@example.com"
  #
  #    ----------------------------------------------------------------------
  class Dictionary < Hash

    attr_accessor :backing_filepath, :section_id


    # Create either a new empty dictionary or unmarshal (deserialize) the
    # dictionary from an encrypted file depending on whether a file exists
    # at the backing_file parameter location.
    #
    # If the backing file indeed exists, the crypt key will be employed to
    # decode and then decrypt the contents before the unmarshal operation.
    #
    # The filepath is stored as an instance variable hence the {write}
    # operation does not need to be told <b>where to?</b>
    #
    # @example
    #    # Create Dictionary the first time
    #    my_dictionary = Dictionary.create( "/path/to/backing/file" )
    #
    #    # Create Dictionary from an Encrypted Backing File
    #    my_dictionary = Dictionary.create( "/path/to/backing/file", "crypt-key-1234-wxyz" )
    #
    # @param backing_file [String]
    #    the backing file is the filepath to this Dictionary's encrypted
    #    backing file when serialized. If no file exists at this path the
    #    operation will instantiate and return a new empty {Hash} object.
    #
    # @param crypt_key [String]
    #    if the backing file exists then this parameter must contain a
    #    robust symmetric decryption key. The symmetric key will be used
    #    for decryption after the base64 encoded file is read.
    #
    #    Note that the decryption key is never part of the dictionary object.
    #    This class method knows it but the new Dictionary has no crypt key
    #    instance variable. Another crypt key must then be introduced when
    #    serializing (writing) the dictionary back into a file.
    #
    # @return [Dictionary]
    #    return a new Dictionary that knows where to go if it needs
    #    to read (deserialize) or write (serialize) itself.
    #
    #    If no file exists at the path a new empty {Hash} object is
    #    returned.
    #
    #    If a file exists, then the crypt_key parameter is expected
    #    to be the decryption and key and the dictionary will be based
    #    on the decrypted contents of the file.
    #
    # @raise [ArgumentError]
    #    An {ArgumentError} is raised if either no decryption key is provided
    #    or one that is unsuitable (ie was not used within the encryption).
    #    Errors can also arise if the block coding and decoding has not been
    #    done satisfactorily.
    def self.create backing_file, crypt_key = nil

      key_missing = File.file?( backing_file ) && crypt_key.nil?
      raise ArgumentError, "No crypt key provided for file #{backing_file}" if key_missing

      dictionary = Dictionary.new
      dictionary.backing_filepath = backing_file

      return dictionary unless File.file? backing_file

      file_contents = File.read( backing_file ).strip
      plaintext_str = file_contents.block_decode_decrypt( crypt_key )
      dictionary.ingest_contents( plaintext_str )

      return dictionary
      
    end


    # Create either a new dictionary containing the specified section or unmarshal
    # (deserialize) the dictionary from an encrypted file depending on whether a
    # file exists at the backing_file parameter location and then <b>create</b> the
    # section <b>only if it does not exist</b>.
    #
    # If the backing file indeed exists, the crypt key will be employed to
    # decode and then decrypt the contents before the unmarshal operation.
    #
    # The filepath is stored as an instance variable hence the {write}
    # operation does not need to be told <b>where to?</b>
    #
    # This dictionary will also know which <b>"section"</b> should be used to
    # put, add, update and delete key/value data. You can employ this dictionary
    # such that <b>each instance only creates, updates, removes and/or reads</b>
    # from a single section.
    #
    # @example
    #    # Create Dictionary the first time with a section.
    #    my_dictionary = Dictionary.create( "/path/to/file", "Europe" )
    #
    #    # Create Dictionary from an Encrypted Backing File
    #    my_dictionary = Dictionary.create( "/path/to/file", "Europe", "1234-wxyz" )
    #
    # @param backing_file [String]
    #    the backing file is the filepath to this Dictionary's encrypted
    #    backing file when serialized.
    #
    # @param section_id [String]
    #    the created dictionary know which <b>section</b> should be used to
    #    put, add, update and delete key/value data. If the backing file
    #    does not exist a new section is created in the empty dictionary.
    #
    #    If the file exists a new section is created only if it is not
    #    already present inside the dictionary.
    #
    # @param crypt_key [String]
    #    if the backing file exists then this parameter must contain a
    #    robust symmetric decryption key. The symmetric key will be used
    #    for decryption after the base64 encoded file is read.
    #
    #    Note that the decryption key is never part of the dictionary object.
    #    This class method knows it but the new Dictionary has no crypt key
    #    instance variable. Another crypt key must then be introduced when
    #    serializing (writing) the dictionary back into a file.
    #
    # @return [Dictionary]
    #    return a new Dictionary that knows where to go if it needs
    #    to read (deserialize) or write (serialize) itself.
    #
    #    If no file exists at the path a new empty {Hash} object is
    #    returned.
    #
    #    If a file exists, then the crypt_key parameter is expected
    #    to be the decryption and key and the dictionary will be based
    #    on the decrypted contents of the file.
    #
    # @raise [ArgumentError]
    #    An {ArgumentError} is raised if either no decryption key is provided
    #    or one that is unsuitable (ie was not used within the encryption).
    #    Errors can also arise if the block coding and decoding has not been
    #    done satisfactorily.
    def self.create_with_section backing_file, section_id, crypt_key = nil

      dictionary = create( backing_file, crypt_key = nil )
      dictionary.section_id = section_id
      dictionary[section_id] = {} unless dictionary.has_key?( section_id )

      return dictionary
      
    end


    # Write the data in this dictionary hash map into a file-system
    # backend mirror whose path was specified in the {Dictionary.create}
    # factory method.
    #
    # Technology for encryption at rest is mandatory when using this
    # Dictionary to write and read files from the filesystem.
    #
    # Calling this {self.write} method when the file at the prescribed path
    # does not exist results in the directory structure being created
    # (if necessary) and then the (possibly encrypted) file being written.
    #
    # @param crypt_key [String]
    #    this parameter must contain a robust symmetric crypt key to use for
    #    the encryption before writing to the filesystem.
    #
    #    Note that the decryption key is never part of the dictionary object.
    #    For uncrackable security this key must be changed every time the
    #    file is written.
    def write crypt_key

      ini_file = IniFile.new
      self.each_key do |section_name|
        ini_file[section_name] = self[section_name]
      end

      crypted_text = ini_file.to_s.encrypt_block_encode( crypt_key )

      FileUtils.mkdir_p File.dirname(@backing_filepath)
      File.write @backing_filepath, crypted_text

    end



    def get key_name
      return self[@section_id][key_name]
    end



    def put key_name, key_value
      self[@section_id][key_name] = key_value
    end




    # Ingest the contents of the INI string and merge it into a
    # this object which is a {Hash}.
    #
    # @param the_contents [String]
    #    the INI string that will be ingested and morphed into
    #    this dictionary.
    #
    # @raise [ArgumentError]
    #    if the content contains any nil section name, key name
    #    or key value.
    def ingest_contents the_contents
      
      ini_file = IniFile.new( :content => the_contents )
      ini_file.each do | data_group, data_key, data_value |
        ingest_entry data_group, data_key, data_value
      end

    end


    private


    def ingest_entry section_name, key_name, value

      msg = "A NIL object detected during ingestion of file [#{@filepath}]."
      raise ArgumentError.new msg if section_name.nil? || key_name.nil? || value.nil?

      if self.has_key? section_name then
        self[section_name][key_name] = value
      else
        self.store section_name, { key_name => value }
      end

    end


  end


end
