#!/usr/bin/ruby
	
module SafeDb

  # The wipe use case clears out any sensitive information from the clipboard.
  # Typically it will be called after the copy use case has placed line values
  # into both the primary and secondary clipboards (Ctrl-v and middle-click).
  class Wipe < Controller

    def execute()

      system "printf \"safe wiped the clipboard on #{TimeStamp.readable()}.\" | xclip"
      system "printf \"safe wiped the clipboard on #{TimeStamp.readable()}.\" | xclip -selection clipbaord"

      puts ""
      puts "safe has wiped the clipboards."
      puts ""

    end

  end

end
