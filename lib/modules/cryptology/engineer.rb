#!/usr/bin/ruby

module SafeDb

  module ToolBelt


  require 'securerandom'

  # This class will be refactored into an interface implemented by a set
  # of plugins that will capture sensitive information from users from an
  # Ubuntu, Windows, RHEL, CoreOS, iOS or CentOS command line interface.
  #
  # An equivalent REST API will also be available for bringing in sensitive
  # information in the most secure (but simple) manner.
  class Engineer


    # --
    # -- Get a viable machine password taking into account the human
    # -- password length and the specified mix_ratio.
    # --
    # -- machine password length = human password length * mix_ratio - 1
    # --
    def self.machine_key human_password_length, mix_ratio

      machine_raw_secret = strong_key( human_password_length * ( mix_ratio + 1) )
      return machine_raw_secret[ 0..( human_password_length * mix_ratio - 1 ) ]

    end


    # --
    # -- Engineer a raw password that is similar (approximate) in
    # -- length to the integer parameter.
    # --
    def self.strong_key approx_length

      non_alphanum = SecureRandom.urlsafe_base64(approx_length);
      return non_alphanum.delete("-_")

    end


    # Amalgamate the parameter passwords using a specific mix ratio. This method
    # produces cryptographically stronger secrets than algorithms that simply
    # concatenate two string keys together. If knowledge of one key were gained, this
    # amalgamation algorithm still provides extremely strong protection even when
    # one of the keys has a single digit length.
    #
    # This +length constraint formula+ binds the two input strings together with
    # the integer mix ratio.
    #
    # <tt>machine password length = human password length * mix_ratio - 1</tt>
    #
    # @param human_password [String] the first password (shorter one) to amalgamate
    # @param machine_password [String] the second password (longer one) to amalgamate
    # @param mix_ratio [Fixnum] the mix ratio that must be respected by the
    #    previous two parameters.
    # @return [String] an amalgamated (reproducible) union of the 2 parameter passwords
    #
    # @raise [ArgumentError] if the length constraint assertion does not hold true
    def self.get_amalgam_password human_password, machine_password, mix_ratio

      size_error_msg = "Human pass length times mix_ratio must equal machine pass length."
      lengths_are_perfect = human_password.length * mix_ratio == machine_password.length
      raise ArgumentError.new size_error_msg unless lengths_are_perfect

      machine_passwd_chunk = 0
      amalgam_passwd_index = 0
      amalgamated_password = ""

      human_password.each_char do |passwd_char|

        amalgamated_password[amalgam_passwd_index] = passwd_char
        amalgam_passwd_index += 1

        for i in 0..(mix_ratio-1) do
          machine_pass_index = machine_passwd_chunk * mix_ratio + i
          amalgamated_password[amalgam_passwd_index] = machine_password[machine_pass_index]
          amalgam_passwd_index += 1
        end

        machine_passwd_chunk += 1

      end

      return amalgamated_password

    end


  end


  end


end
