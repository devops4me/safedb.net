#!/usr/bin/ruby
	
module SafeDb

  # The wipe use case clears out any sensitive information from the clipboard.
  # Typically it will be called after the copy use case has placed line values
  # into both the primary and secondary clipboards (Ctrl-v and middle-click).
  class Wipe < Controller

    def execute()

      log.info(x){ "Which Operating System is running? #{OpSys.get_host_os_string()}" }

      if( OpSys.is_mac_os?() )
        system "printf \"safe wiped the clipboard on #{TimeStamp.readable()}.\" | pbcopy"
        wiped_feedback()
        return
      end

      system "printf \"safe wiped the clipboard on #{TimeStamp.readable()}.\" | xclip"
      system "printf \"safe wiped the clipboard on #{TimeStamp.readable()}.\" | xclip -selection clipbaord"
      wiped_feedback()

    end

    private

    def wiped_feedback()

      puts ""
      puts "safe has wiped the clipboard."
      puts ""

    end

  end

end
