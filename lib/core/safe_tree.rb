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
      master_crypts_folder = File.join( Indices::SAFE_DATABASE_FOLDER, Indices::MASTER_CRYPTS_FOLDER_NAME )
      return File.join( master_crypts_folder, "safedb.book.#{book_id}" )
    end


    def self.branch_crypts_filepath( book_id, branch_id, content_id )
      return File.join( branch_crypts_folder( book_id, branch_id ), "safedb.chapter.#{content_id}.txt" )
    end


    def self.branch_crypts_folder( book_id, branch_id )
      branch_crypts_folder = File.join( Indices::SAFE_DATABASE_FOLDER, Indices::BRANCH_CRYPTS_FOLDER_NAME  )
      return File.join( branch_crypts_folder, "safedb-session-#{book_id}-#{branch_id}" )
    end


    def self.branch_indices_filepath( branch_id )
      branch_indices_folder = File.join( Indices::SAFE_DATABASE_FOLDER, Indices::BRANCH_INDICES_FOLDER_NAME )
      return File.join( branch_indices_folder, "safedb-indices-#{branch_id}.ini" )
    end


  end


end
