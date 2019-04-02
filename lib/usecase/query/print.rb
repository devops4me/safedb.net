#!/usr/bin/ruby
	
module SafeDb

  # The print use case prints out a credential value without a line
  # feed or any other contextual information.
  #
  # Print is perfect for reading values from scripts or using unix
  # like pipe behaviour to pass credentials to other commands.
  class Print < QueryVerse

    attr_writer :key_name

    # Use the chapter and verse setup to read the parameter {@key_name}
    # and print its corresponding value without a line feed or return.
    def query_verse()

      print @verse[ @key_name ]

    end


  end


end
