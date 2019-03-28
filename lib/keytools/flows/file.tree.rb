#!/usr/bin/ruby

module SafeDb

  # This class knows the location of the main indices and crypt files
  # and folders both for the master and session lines.
  #
  # More importantly, it knows where the master crypts and indices are
  # given a book id, and also the session crypts and indices, given a
  # session id.
  class FileTree


    def self.master_crypts_filepath( book_id, content_id )
      return File.join( master_crypts_folder( book_id ), "safedb.chapter.#{content_id}.txt" )
    end

    def self.master_crypts_folder( book_id )
      return File.join( MASTER_CRYPTS_FOLDER, "safedb.book.#{book_id}" )
    end


    def self.session_crypts_filepath( book_id, session_id, content_id )
      return File.join( session_crypts_folder( book_id, session_id ), "safedb.chapter.#{content_id}.txt" )
    end


    def self.session_crypts_folder( book_id, session_id )
      return File.join( SESSION_CRYPTS_FOLDER, "safedb-session-#{book_id}-#{session_id}" )
    end


    def self.session_indices_filepath( session_id )
      return File.join( SESSION_INDICES_FOLDER, "safedb-indices-#{session_id}.ini" )
    end


    private

    SAFE_DATABASE_FOLDER   = File.join( Dir.home, ".#{Indices::SAFEDB_URL_NAME}" )
    MASTER_CRYPTS_FOLDER   = File.join( SAFE_DATABASE_FOLDER, Indices::MASTER_CRYPTS_FOLDER_NAME   )
    SESSION_INDICES_FOLDER = File.join( SAFE_DATABASE_FOLDER, Indices::SESSION_INDICES_FOLDER_NAME )
    SESSION_CRYPTS_FOLDER  = File.join( SAFE_DATABASE_FOLDER, Indices::SESSION_CRYPTS_FOLDER_NAME  )


  end


end
