#!/usr/bin/ruby
# coding: utf-8

module SafeDb

  require 'json'

  # A Key/Value database knows how to manipulate a JSON backed data structure
  # (put, add etc) <b>after reading and then decrypting it</b> from a
  # file and <b>before encrypting and then writing it</b> to a file.
  #
  # It provides behaviour to which we can create, append (add), update
  # (change), read parts and delete essentially two structures
  #
  # - a collection of name/value pairs
  # - an  ordered list of values
  #
  # == JSON is Not Exposed in the Interface
  #
  # A key/value database doesn't expose the data format used in the implementation
  # allowing this to be changed seamlessly to YAMl or other formats.
  #
  # == Symmetric Encryption and Decryption
  #
  # A key/value database supports operations to <b>read from</b> and <b>write to</b>
  # a known filepath and with a symmetric key it can
  #
  # - decrypt <b>after reading from</b> a file and
  # - encrypt <b>before writing to</b> a (the same) file
  #
  # == Hashes as the Primary Data Structure
  #
  # The key/value database openly extends {Hash} as the data structure for holding
  #
  # - strings
  # - arrays
  # - other hashes
  # - booleans
  # - integers and floats
  class KeyDb < Hash

    # Return a key database data structure that is instantiated from
    # the parameter JSON string.
    #
    # @param db_json_string [String]
    #    this json formatted data structure will be converted into a
    #    a Ruby hash (map) data structure and returned.
    #
    # @return [KeyDb]
    #    a hash data structure that has been instantiated as per the
    #    parameter json string content.
    def self.from_json( db_json_string )

      data_db = KeyDb.new()
      data_db.merge!( JSON.parse( db_json_string ) )
      return data_db

    end



    # Create a new key value entry inside a dictionary with the specified
    # name at the root of this database. Successful completion means the
    # named dictionary will contain one more entry than it need even if it
    # did not previously exist.
    #
    # @param dictionary_name [String]
    #
    #    if a dictionary with this name exists at the root of the
    #    database add the parameter key value pair into it.
    #
    #    if no dictionary exists then create one first before adding
    #    the key value pair as the first entry into it.
    #
    # @param key_name [String]
    #
    #    the key part of the key value pair that will be added into the
    #    dictionary whose name was provided in the first parameter.
    #
    # @param value [String]
    #
    #    the value part of the key value pair that will be added into the
    #    dictionary whose name was provided in the first parameter.
    def create_entry( dictionary_name, key_name, value )

      KeyError.not_new( dictionary_name, self )
      KeyError.not_new( key_name, self )
      KeyError.not_new( value, self )

      self[ dictionary_name ] = {} unless self.has_key?( dictionary_name )
      self[ dictionary_name ][ key_name ] = value

    end


    # Create a new secondary tier map key value entry inside a primary tier
    # map at the map_key_name location.
    #
    # A failure will occur if either the outer or inner keys already exist
    # without their values being map objects.
    #
    # If this method is called against a new empty map, the resulting map
    # structure will look like the below.
    #
    #     { outer_keyname ~> { inner_keyname ~> { entry_keyname, entry_value } } }
    #
    # @param outer_keyname [String]
    #
    #    if a dictionary with this name exists at the root of the
    #    database add the parameter key value pair into it.
    #
    #    if no dictionary exists then create one first before adding
    #    the key value pair as the first entry into it.
    #
    # @param inner_keyname [String]
    #
    #    if a map exists at this key name then an entry comprising of
    #    a map_entry_key and a entry_value may either be added
    #    (if the map_entry_key does not already exist), or updated if
    #    it does.
    #
    #    if the map does not exist it will be created and its first and
    #    only entry will be a key with inner_keyname along with a new
    #    single entry map consisting of the entry_keyname and the
    #    entry_value.
    #
    # @param entry_keyname [String]
    #
    #    this key will exist in the second tier map after this operation.
    #
    # @param entry_value [String]
    #
    #    this value will exist in the second tier map after this operation
    #    and if the entry_keyname already existed its value is overwritten
    #    with this one.
    #
    def create_map_entry( outer_keyname, inner_keyname, entry_keyname, entry_value )

      KeyError.not_new( outer_keyname, self )
      KeyError.not_new( inner_keyname, self )
      KeyError.not_new( entry_keyname, self )
      KeyError.not_new( entry_value,   self )

      self[ outer_keyname ] = {} unless self.has_key?( outer_keyname )
      self[ outer_keyname ][ inner_keyname ] = {} unless self[ outer_keyname ].has_key?( inner_keyname )
      self[ outer_keyname ][ inner_keyname ][ entry_keyname ] = entry_value

    end


    # Does this database have an entry in the root dictionary named with
    # the key_name parameter?
    #
    # @param dictionary_name [String]
    #
    #    immediately return false if a dictionary with this name does
    #    <b>not exist</b> at the root of this database.
    #
    # @param key_name [String]
    #
    #    test whether a key/value pair answering to this name exists inside
    #    the specified dictionary at the root of this database.
    #
    def has_entry?( dictionary_name, key_name )

      KeyError.not_new( dictionary_name, self )
      KeyError.not_new( key_name, self )

      return false unless self.has_key?( dictionary_name )
      return self[ dictionary_name ].has_key?( key_name )

    end


    # Get the entry with the key name in a dictionary that is itself
    # inside another dictionary (named in the first parameter) which
    # thankfully is at the root of this database.
    #
    # Only call this method if {has_entry?} returns true for the same
    # dictionary and key name parameters.
    #
    # @param dictionary_name [String]
    #
    #    get the entry inside a dictionary which is itself inside a
    #    dictionary (with this dictionary name) which is itself at the
    #    root of this database.
    #
    # @param key_name [String]
    #
    #    get the value part of the key value pair that is inside a
    #    dictionary (with the above dictionary name) which is itself
    #    at the root of this database.
    #
    def get_entry( dictionary_name, key_name )

      return self[ dictionary_name ][ key_name ]

    end


    # Delete an existing key value entry inside the dictionary with the specified
    # name at the root of this database. Successful completion means the
    # named dictionary will contain one less entry if that key existed.
    #
    # @param dictionary_name [String]
    #
    #    if a dictionary with this name exists at the root of the
    #    database add the parameter key value pair into it.
    #
    #    if no dictionary exists throw an error
    #
    # @param key_name [String]
    #
    #    the key part of the key value pair that will be deleted in the
    #    dictionary whose name was provided in the first parameter.
    def delete_entry( dictionary_name, key_name )

      KeyError.not_new( dictionary_name, self )
      KeyError.not_new( key_name, self )

      self[ dictionary_name ].delete( key_name )

    end


    # Read and inject into this envelope, the data structure found in a
    # file at the path specified in the first parameter.
    #
    # Symmetric cryptography is mandatory for the envelope so we must
    # <b>encrypt before writing</b> and <b>decrypt after reading</b>.
    #
    # An argument error will result if a suitable key is not provided.
    #
    # If the file does not exist (denoting the first read) all this method
    # does is to stash the filepath as an instance variable and igore the
    # decryption key which can be nil (or ommitted).
    #
    # @param the_filepath [String]
    #     absolute path to the file which acts as the persistent mirror to
    #     this data structure envelope.
    #
    # @param decryption_key [String]
    #     encryption at rest is a given so this mandatory parameter must
    #     contain a robust symmetric decryption key. The key will be used
    #     for decryption after the read and it will not linger (ie not cached
    #     as an instance variable).
    #
    # @raise [ArgumentError] if the decryption key is not robust enough.
    def read the_filepath, decryption_key = nil

      # @todo -> this is confused - it uses INI but above methods use JSON
      # @todo -> this is confused - it uses INI but above methods use JSON
      # @todo -> this is confused - it uses INI but above methods use JSON
      # @todo -> this is confused - it uses INI but above methods use JSON
      # @todo -> this is confused - it uses INI but above methods use JSON
      # @todo -> this is confused - it uses INI but above methods use JSON
      # @todo -> this is confused - it uses INI but above methods use JSON
      # @todo -> this is confused - it uses INI but above methods use JSON
      # @todo -> this is confused - it uses INI but above methods use JSON
      # @todo -> this is confused - it uses INI but above methods use JSON

      raise RuntimeError, "This KeyDb.read() software is never called so how can I be here?"

      @filepath = the_filepath
      return unless File.exists? @filepath

      cipher_text = Base64.decode64( File.read( @filepath ).strip )
      plain_text = ToolBelt::Blowfish.decryptor( cipher_text, decryption_key )

      data_structure = JSON.parse plain_text
      self.merge! data_structure

    end


    # Write the data in this envelope hash map into a file-system
    # backed mirror whose path was specified in the {self.read} method.
    #
    # Technology for encryption at rest is supported by this dictionary
    # and to this aim, please endeavour to post a robust symmetric
    # encryption key.
    #
    # Calling this {self.write} method when the file at the prescribed path
    # does not exist results in the directory structure being created
    # (if necessary) and then the encrypted file being written.
    #
    # @param encryption_key [String]
    #     encryption at rest is a given so this mandatory parameter must
    #     contain a robust symmetric encryption key. The symmetric key will
    #     be used for the decryption after the read. Note that the decryption
    #     key does not linger meaning it isn't cached in an instance variable.
    def write encryption_key

      # @todo -> this is confused - it uses INI but above methods use JSON
      # @todo -> this is confused - it uses INI but above methods use JSON
      # @todo -> this is confused - it uses INI but above methods use JSON
      # @todo -> this is confused - it uses INI but above methods use JSON
      # @todo -> this is confused - it uses INI but above methods use JSON
      # @todo -> this is confused - it uses INI but above methods use JSON
      # @todo -> this is confused - it uses INI but above methods use JSON
      # @todo -> this is confused - it uses INI but above methods use JSON
      # @todo -> this is confused - it uses INI but above methods use JSON

      raise RuntimeError, "This KeyDb.write( key ) software is never called so how can I be here?"

      FileUtils.mkdir_p(File.dirname(@filepath))
      cipher_text = Base64.encode64 ToolBelt::Blowfish.encryptor( self.to_json, encryption_key )
      File.write @filepath, cipher_text

      puts ""
      puts "=== ============================"
      puts "=== Envelope State ============="
      puts "=== ============================"

      a_ini_file = IniFile.new
      self.each_key do |section_name|
        a_ini_file[section_name] = self[section_name]
      end
      puts a_ini_file.to_s

      puts "=== ============================"
      puts ""

    end


  end


end
