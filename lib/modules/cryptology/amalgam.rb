#!/usr/bin/ruby

module SafeDb

  module ToolBelt


  # This class knows how to amalgamate passwords, keys and string data in
  # a manner that is the cryptographical equivalent of synergy.
  #
  # The amalgamated keys are synergially (cryptographically) greater than
  # the sum of their parts.
  class Amalgam

    # Amalgamate the two parameter passwords in a manner that is the
    # cryptographical equivalent of synergy. The amalgamated keys are
    # synergially greater than the sum of their parts.
    #
    # -- Get a viable machine password taking into account the human
    # -- password length and the specified mix_ratio.
    #
    #
    # @param human_password [String] the password originating from a human
    # @param machine_key [String] a machine engineered ascii password (key)
    # @mixparam machine_key [String] a machine engineered ascii password (key)
    #
    # @return [String] the union of the two parameter passwords
    #
    # @raise [ArgumentError] when the size of the two passwords and the
    #     mix ratio do not conform to the constraint imposed by the below
    #     equation which must hold true.
    #     <tt>machine password length = human password length * mix_ratio - 1</tt>
    #
    def self.passwords human_password, machine_password, mix_ratio

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
