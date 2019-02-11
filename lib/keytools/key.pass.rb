#!/usr/bin/ruby
# coding: utf-8

module OpenKey

  class KeyPass


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
      # @param prompt_twice [Boolean] indicate whether the user should be
      #    prompted twice. If true the prompt_2 text must be provided and
      #    converse is also true. A true value asserts that both times the
      #    user enters the same (case sensitive) string.
      #
      # @return [String] the collected string text ( watch out for non-ascii chars)
      # @raise [ArgumentError] if the minimum size is less than one
      def self.password_from_shell prompt_twice

        assert_min_size MINIMUM_PASSWORD_SIZE

        sleep(1)
        puts "Password:"
        first_secret = STDIN.noecho(&:gets).chomp

        assert_input_text_size first_secret.length, MINIMUM_PASSWORD_SIZE
        return first_secret unless prompt_twice

        sleep(1)
        puts "Re-enter the password:"
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

      private

      MINIMUM_PASSWORD_SIZE = 4


  end


end
