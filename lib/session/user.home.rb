#!/usr/bin/ruby

# coding: utf-8

# opensession contains basic behaviour for managing a client only
# (serverless) session. Configuration directives are read and written
# from an INI off the home directory that is created when the session
# is first initiated.
module OpenSession

  # This singleton class ascertains the users home folder in a manner
  # agnositic to whether the software is running on Linux or Windows.
  class Home
    include Singleton

    # This static behaviour reads the [home folder] just once.
    def self.dir
      return Home.instance.folder
    end

    # This static behaviour reads the [username] just once.
    def self.usr
      return Home.instance.username
    end

    attr_reader :folder
    attr_reader :username

    # Ascertain the home folder location.
    def initialize

      # On Windows the home folder may end with [AppData/Roaming].
      extraneous_path = "/AppData/Roaming"

      @folder  = Dir.home
      @username = @folder.split("/").last
      return unless Dir.home.end_with? extraneous_path

      # Remove the tail [AppData/Roaming] from the home path.
      @folder = Dir.home.gsub extraneous_path, ""
      @username = @folder.split("/").last

    end


  end


end
