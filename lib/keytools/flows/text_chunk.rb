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
      Safe Version := safedb v#{SafeDb::VERSION}
      Safe Website := #{Indices::SAFE_GEM_WEBSITE}
      RubyGems.org := https://rubygems.org/gems/safedb
      CRYPT_HEADER

    end


  end


end
