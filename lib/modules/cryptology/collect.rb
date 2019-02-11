#!/usr/bin/ruby

module SafeDb

  module ToolBelt

    require 'io/console'

    # This class will be refactored into an interface implemented by a set
    # of plugins that will capture sensitive information from users from an
    # Ubuntu, Windows, RHEL, CoreOS, iOS or CentOS command line interface.
    #
    # An equivalent REST API will also be available for bringing in sensitive
    # information in the most secure (but simple) manner.
    class Collect


      # <tt>Collect something sensitive from the command line</tt> with a
      # minimum length specified in the first parameter. This method can't
      # know whether the information is a password, a pin number or whatever
      # so it takes the integer minimum size at its word.
      #
      # <b>Question 5 to App Config | What is the Secret?</b>
      #
      # The client may need to acquire the secret if the answer to question 4 indicates the need
      # to instantiate the keys and encrypt the application's plaintext database. The application
      # should facilitate communication of the secret via
      #
      # - an environment variable
      # - the system clipboard (cleared after reading)
      # - a file whose path is a command parameter
      # - a file in a pre-agreed location
      # - a file in the present directory (with a pre-agreed name)
      # - a URL from a parameter or pre-agreed
      # - the shell's secure password reader
      # - the DConf / GConf or GSettings configuration stores
      # - a REST API
      # - password managers like LastPass, KeePassX or 1Pass
      # - the Amazon KMS (Key Management Store)
      # - vaults from Ansible, Terraform and Kubernetes
      # - credential managers like GitSecrets and Credstash
      #
      # @param min_size [Integer] the minimum size of the collected secret
      #    whereby one (1) is the least we can expect. The maximum bound is
      #    not constrained here so will fall under what is allowed by the
      #    interface, be it a CLI, Rest API, Web UI or Mobile App.
      #
      # @param prompt_twice [Boolean] indicate whether the user should be
      #    prompted twice. If true the prompt_2 text must be provided and
      #    converse is also true. A true value asserts that both times the
      #    user enters the same (case sensitive) string.
      #
      # @param prompt_1 [String] the text (aide memoire) used to prompt the user
      #
      # @param prompt_2 [String] if the prompt twice boolean is TRUE, this
      #    second prompt (aide memoire) must be provided.
      #
      # @return [String] the collected string text ( watch out for non-ascii chars)
      # @raise [ArgumentError] if the minimum size is less than one
      def self.secret_text min_size, prompt_twice, prompt_1, prompt_2=nil

        assert_min_size min_size

        sleep(1)
        puts "\n#{prompt_1} : "
        first_secret = STDIN.noecho(&:gets).chomp

        assert_input_text_size first_secret.length, min_size
        return first_secret unless prompt_twice

        sleep(1)
        puts "\n#{prompt_2} : "
        check_secret = STDIN.noecho(&:gets).chomp

        assert_same_size_text first_secret, check_secret
        
        return first_secret

      end


      # --
      # -- Raise an exception if asked to collect text that is less
      # -- than 3 characters in length.
      # --
      def self.assert_min_size min_size

        min_length_msg = "\n\nCrypts with 2 (or less) characters open up exploitable holes.\n\n"
        raise ArgumentError.new min_length_msg if min_size < 3

      end


      # --
      # -- Output an error message and then exit if the entered input
      # -- text size does not meet the minimum requirements.
      # --
      def self.assert_input_text_size input_size, min_size

        if( input_size < min_size  )

          puts
          puts "Input is too short. Please enter at least #{min_size} characters."
          puts

          exit

        end

      end


      # --
      # -- Assert that the text entered the second time is exactly (case sensitive)
      # -- the same as the text entered the first time.
      # --
      def self.assert_same_size_text first_text, second_text
        
        unless( first_text.eql? second_text )

          puts
          puts "Those two bits of text are not the same (in my book)!"
          puts

          exit

        end

      end


    end


  end


end
