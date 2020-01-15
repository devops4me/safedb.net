#!/usr/bin/ruby
	
module SafeDb

  # The safe send command is used to transmit the contents of a book, chapter,
  # verse or line using common messaging frameworks such as email, SMS and slack.
  # Docker Secrets, HashiCorp's Vault and more besides.
  #
  # Navigate using `safe open` or `safe goto` to the chapter or verse that you
  # wish to send and simply specify the message destination be it an email address
  # or a mobile phone number.
  #
  # - `safe send colleague@example.com`
  # - `safe send 07500765432`
  #
  # Visit documentation at https://www.safedb.net/docs/send
  class Send < QueryVerse

    def query_verse()


    end


  end


end
