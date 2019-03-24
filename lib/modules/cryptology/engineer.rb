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
    # -- Engineer a raw password that is similar (approximate) in
    # -- length to the integer parameter.
    # --
    def self.strong_key approx_length

      non_alphanum = SecureRandom.urlsafe_base64(approx_length);
      return non_alphanum.delete("-_")

    end


  end


  end


end
