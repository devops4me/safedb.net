#!/usr/bin/ruby

module SafeDb

  # These textual chunks will hold information blocks that are printed into files
  # or printed out for user consumption on standard out.
  class TextChunk

    # Construct the header for the ciphertext content files written out
    # onto the filesystem including information such as the application version
    # and human readable time.
    #
    # @param book_id [String] the identifier of the book that is being queried and edited
    # @return [String] a textual block that can be printed at the top of crypt files
    def self.crypt_header( book_id )

      <<-CRYPT_HEADER
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#{Indices::SAFE_URL_NAME} ciphertext block
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Safe Book Id := #{book_id}
Time Created := #{KeyNow.readable()}
Safe Version := #{Indices::SAFE_VERSION_STRING}
Safe Website := #{Indices::SAFE_GEM_WEBSITE}
RubyGems.org := https://rubygems.org/gems/safedb
CRYPT_HEADER

    end


    # Print a message stating that the book cannot be accessed until
    # a successful login has occured.
    def self.not_logged_in_message()

      <<-NOT_LOGGED_IN_MESSAGE

  Please login to access the credentials in this book.
  Suppose you initialized a book called websites.

    #{Indices::COMMANDER} login websites
     #{Indices::COMMANDER} login websites --password=secret123
    #{Indices::COMMANDER} login websites --clip

  A space before the command keeps it out of ~/.bash_history
NOT_LOGGED_IN_MESSAGE

    end


    # Print a message stating that the book has not been opened at any
    # chapter and verse location.
    def self.not_open_message()

      <<-UNOPENED_MESSAGE

  Please open a chapter and verse to put, edit or query data.

     #{Indices::COMMANDER} open contacts monica

  then add monica's contact details

     #{Indices::COMMANDER} put email monica.lewinsky@gmail.com
     #{Indices::COMMANDER} put phone +1-357-246-8901
     #{Indices::COMMANDER} put twitter @monica_x
     #{Indices::COMMANDER} put skype.id 6363430539
     #{Indices::COMMANDER} put birthday \"1st April 1978\"

  also hilary's

     #{Indices::COMMANDER} open contacts hilary
     #{Indices::COMMANDER} put email hilary@whitehouse.gov

  then save the changes to your book and logout."

     #{Indices::COMMANDER} commit"
     #{Indices::COMMANDER} logout"

UNOPENED_MESSAGE

    end


  end


end
