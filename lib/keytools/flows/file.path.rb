#!/usr/bin/ruby

module SafeDb

  # This filepath knows where the safe directory tree is and more importantly,
  # it knows where the master crypts and indices are given a book id, and also
  # the session crypts and indices, given a session id.
  class FilePath


    def self.create_master_book_crypts_folder( book_id )
      FileUtils.mkdir_p( master_crypts_folder( book_id ) )
    end


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


    def self.contains_all_master_book_indices( key_map )
      return false unless key_map.contains?( Indices::CONTENT_RANDOM_IV )
      return false unless key_map.contains?( Indices::CONTENT_IDENTIFIER )
      return false unless key_map.contains?( Indices::INTER_SESSION_KEY_CRYPT )
      return false unless key_map.contains?( Indices::MASTER_COMMIT_ID )
      return true
    end


    private


    SAFE_DATABASE_FOLDER   = File.join( Dir.home, ".safedb.net" )
    MASTER_CRYPTS_FOLDER   = File.join( SAFE_DATABASE_FOLDER, "safedb-master-crypts"   )
    SESSION_INDICES_FOLDER = File.join( SAFE_DATABASE_FOLDER, "safedb-session-indices" )
    SESSION_CRYPTS_FOLDER  = File.join( SAFE_DATABASE_FOLDER, "safedb-session-crypts"  )


  end


end
