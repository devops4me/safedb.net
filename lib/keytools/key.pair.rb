#!/usr/bin/ruby
# coding: utf-8

module SafeDb

  require 'inifile'

  # KeyPair is a <b>key-value</b> store backed by a plain-text file in
  # an <b>INI format</b> that sits on an accessible file-system.
  #
  #
  # == Example Data Exchange
  #
  # Issue the below ruby calls and specify a /path/to/file
  #
  #    keymap = KeyPair.new ( "/path/to/file" )
  #
  #    keymap.use ( "phone_numbers"           )
  #    keymap.set ( "joe", "0044 7500 123456" )
  #    keymap.set ( "amy", "0044 7678 123456" )
  #
  # Now visit the file to see your exchanged data.
  #
  #    [phone_numbers]
  #    joe = 0044 7500 123456
  #    amy = 0044 7678 123456
  #
  #
  # == The <em>Current</em> Section
  #
  # You can set the <b>current section</b> with the {use} method and then
  # subsequent read, write, or query behaviour will reference the section that
  # you stated.
  #
  # You do not need a new object to switch sections - just go ahead and
  # use another another one.
  #
  # Remember that KeyPair is <b>two-dimensional</b> data structure so all
  # key-value pairs are stored under the auspices of a section.
  #
  # == Key-Value Pair Exchanges
  #
  # Representational state transfer occurs with four methods with
  #
  # - custom sections referenced through {read} and {write}
  # - said sections transfered via ubiquitous {get} and {set}
  #
  # The name given to the default group can be specified to the constructor.
  # If none is provided the aptly named "default" is used.
  class KeyPair

    # Initialize the key value store and auto write a time stamp that
    # has nano-second accuracy with a key whose name is gleened from
    # the constant {KeyData::INIT_TIME_STAMP_NAME}.
    #
    # The path to the backing INI file is gleened from the first
    # backing file path parameter.
    #
    # @param backing_file_path [String]
    #    the expected location of the file-backed key-value store.
    #    If the folder and/or file do not exist the folder is created
    #    and then the file is created along with the time stamps.
    #
    # @param the_default_group [String]
    #    the name of the default group. If none is presented this value
    #    will default to the aptly named "default".
    def initialize backing_file_path
      @file_path = backing_file_path
      create_dir_if_necessary
    end


    # Set the section to use for future data exchanges via the ubiquitous {get}
    # and {set} methods as well as the query {contains} key method.
    #
    # @param the_section_name [String]
    #    the non-nil and non whitespace only section name that will lead a
    #    set of key-value pairs in the INI formatted file.
    def use the_section_name
      raise ArgumentError, "Cannot use a Nil section name." if the_section_name.nil?
      @section_to_use = the_section_name
    end

    # Stash the setting directive and its value into the configuration file
    # using the default settings group.
    #
    # @param key_name [String] the name of the key whose value is to be written
    # @param key_value [String] the data item value of the key specified
    def set key_name, key_value
      raise ArgumentError, "Cannot set a Nil section name." if @section_to_use.nil?
      write @section_to_use, key_name, key_value
    end


    # Stash the setting directive and its value into the configuration file
    # using the default settings group.
    #
    # @param key_name [String] the name of the key whose value is to be written
    # @return [String]
    #    return the value of the configuration directive in the default group
    def get key_name
      raise ArgumentError, "Cannot get from a Nil section name." if @section_to_use.nil?
      read @section_to_use, key_name
    end


    # Write the key/value pair in the parameter into this key/value store's
    # base file-system backing INI file.
    #
    # This method assumes the existence of the backing configuration file at
    # the @file_path instance variable that was set during initialization.
    #
    # Observable value is the written key/value pair within the specified
    # section. The alternate flows are
    #
    # - if the section does not exist it is created
    # - if the section and key exist the value is inserted or overwritten
    #
    # @param section_name [String] name grouping the section of config values
    # @param key [String] the key name of config directive to be written into the file
    # @param value [String] value of the config directive to be written into the file
    #
    def write section_name, key, value

      config_map = IniFile.new( :filename => @file_path, :encoding => 'UTF-8' )
      config_map = IniFile.load( @file_path ) if File.file? @file_path
      config_map[section_name][key] = value
      config_map.write

    end


    # Given the configuration key name and the context name, get the
    # corresponding key value from the configuration file whose path
    # is acquired using the {self#get_filepath} method.
    #
    # @param key_name [String] the key whose value is to be retrieved
    #
    # @return [String] the value configured for the parameter key
    #
    # @raise ArgumentError for any one of a long list of reasons that
    #     cause the key value to not be retrieved. This can range from
    #     non-existent directories and files, non readable files, incorrect
    #     configurations right down to missing keys or even missing values.
    def read section_name, key_name

      raise ArgumentError.new "No section given." if section_name.nil? || section_name.strip.empty?
      raise ArgumentError.new "No parameter key given." if key_name.nil? || key_name.strip.empty?
      raise ArgumentError.new "No file found at [ #{@file_path} ]" unless File.exists? @file_path
      the_text = File.read @file_path
      raise ArgumentError.new "This file is empty => [ #{@file_path} ]" if the_text.empty?

      the_data = IniFile.load @file_path
      key_exists = the_data[ section_name ].has_key?( key_name )
      key_err_msg = "Key [#{key_name}] not found in section [#{section_name}]"
      raise ArgumentError, key_err_msg unless key_exists

      rawvalue = the_data[section_name][key_name]
      key_val_msg = "Nil empty or whitespace value for key [#{section_name}][#{key_name}]"
      nil_empty_or_whitespace = rawvalue.nil? || rawvalue.chomp.strip.empty?
      raise ArgumentError, key_val_msg if nil_empty_or_whitespace

      return rawvalue.chomp.strip

    end


    # Return true if the settings configuration file contains the specified
    # parameter key within the current section name that has been set via
    # the {use} method.
    #
    # This method does not check the contents (value) of the key. Even if it
    # is an empty string, this method returns true so long as the section
    # exists and the key exists within that.
    #
    # @param key_name [String]
    #    does a key with this name exist within the current map section.
    #
    # @return [Boolean]
    #    return true if the current section exists and a key with the parameter
    #    name exists within it.
    #    return false if <b>either</b> the section <b>or</b> the key do not exist.
    #
    # raise [ArgumentError]
    #    if the configuration file does not exist or is empty
    #    if the paramter key_name is nil, empty or contains only whitespace
    def contains? key_name

      raise ArgumentError.new "No parameter key given." if key_name.nil? || key_name.strip.empty?
      raise ArgumentError.new "No file found at [ #{@file_path} ]" unless File.exists? @file_path
      the_text = File.read @file_path
      raise ArgumentError.new "This file is empty => [ #{@file_path} ]" if the_text.empty?

      the_data = IniFile.load @file_path
      return false unless the_data.has_section?( @section_to_use )
      return the_data[ @section_to_use ].has_key?( key_name )

    end



    # Return true if the settings configuration file contains the specified
    # section name. This method ignores whatever section that may or may not
    # have been pointed to by the use command.
    #
    # @param section_name [String]
    #    does a section with this name exist within the file data structure
    #
    # @return [Boolean]
    #    return true if a section exists with the specified name
    def has_section? section_name

      KeyError.not_new( section_name, self )

      raise ArgumentError.new "No file found at [ #{@file_path} ]" unless File.exists? @file_path
      the_text = File.read @file_path
      raise ArgumentError.new "This file is empty => [ #{@file_path} ]" if the_text.empty?

      the_data = IniFile.load @file_path
      return the_data.has_section?( section_name )

    end



    # Get the time stamp that was written to the key-value store at
    # the point it was first initialized and then subsequently written
    # out (serialized) onto the file-system.
    #
    # The time stamp returned marks the first time this key-value store
    # was conceived by a use case actor and subsequently serialized.
    #
    # @return [String]
    #    the string time stamp denoting the first time this key-value
    #    store was first initialized and then subsequently written out
    #    (serialized) onto the file-system.
    def time_stamp
      return get INIT_TIME_STAMP_NAME
    end



    private



    def create_dir_if_necessary

      config_directory = File.dirname @file_path
      return if (File.exist? config_directory) && (File.directory? config_directory)
      FileUtils.mkdir_p config_directory

    end


  end


end
