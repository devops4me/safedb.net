#!/usr/bin/ruby
# coding: utf-8

module SafeDb

  # The operating system class provides information on the operating system
  # that this ruby system is running on top of.
  class OpSys

    # Return a string log of the operating system that this ruby system
    # is running on top of.
    #
    # @return [String] log of the operating system information
    def self.get_opsys_log()
      require 'rbconfig'
      host_os = RbConfig::CONFIG['host_os']
      return "The operating system is #{host_os}."
    end

    # Return true if the operating system is MacOS (a.k.a OSX)
    # @return [Boolean] true if this is the MacOS operating system
    def self.is_mac_os?()
      return get_host_os_string().downcase().include?( "darwin" )
    end

    # Return a string representation of the name of the operating system
    # that this ruby gem is running on top of.
    #
    # @return [String] name of the executing operating system
    def self.get_host_os_string()
      require 'rbconfig'
      host_os = RbConfig::CONFIG['host_os']
      return host_os
    end

  end

end