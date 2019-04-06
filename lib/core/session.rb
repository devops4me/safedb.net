#!/usr/bin/ruby

module SafeDb

  # The shell can access the 152 characters of crypt and salt text
  # that was set (exported) at the beginning when the shell woke up and typically
  # executed its .bash_aliases script.
  class Branch

    def self.to_token()

      raw_env_var_value = ENV[Indices::TOKEN_VARIABLE_NAME]
      raise_token_error( Indices::TOKEN_VARIABLE_NAME, "not present") unless raw_env_var_value

      env_var_value = raw_env_var_value.strip
      raise_token_error( Indices::TOKEN_VARIABLE_NAME, "consists only of whitespace") if raw_env_var_value.empty?

      size_msg = "length should contain exactly #{Indices::TOKEN_VARIABLE_SIZE} characters"
      raise_token_error( Indices::TOKEN_VARIABLE_NAME, size_msg ) unless env_var_value.length == Indices::TOKEN_VARIABLE_SIZE

      return env_var_value

    end


    private


    def self.raise_token_error env_var_name, message

      puts ""
      puts "#{Indices::TOKEN_VARIABLE_NAME} environment variable #{message}."
      puts "To instantiate it you can use the below command."
      puts ""
      puts "$ export #{Indices::TOKEN_VARIABLE_NAME}=`safe token`"
      puts ""
      puts "ps => those are backticks around `safe token` (not apostrophes)."
      puts ""

      raise RuntimeError, "#{Indices::TOKEN_VARIABLE_NAME} environment variable #{message}."

    end


  end


end
