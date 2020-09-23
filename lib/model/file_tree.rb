#!/usr/bin/ruby

module SafeDb

  # This class knows the location of the main indices and crypt files
  # and folders both for the master and branch lines.
  #
  # More importantly, it knows where the master crypts and indices are
  # given a book id, and also the branch crypts and indices, given a
  # branch id.
  #
  # See lib/manual/files-folders.md for more file tree documentation.
  class FileTree

    # Within master, get the path to the book's asset folder.
    # @param book_name [String] the name of the book in question
    # @return [File] path (within master) to the book's assets folder
    def self.master_book_folder( book_name )
      return File.join( Indices::MASTER_CRYPTS_FOLDER_PATH, book_name )
    end

    # RENAME AS master_book_chapters_folder as opposed to branch_book_chapters_folder
    # RENAME AS master_book_chapters_folder as opposed to branch_book_chapters_folder
    # RENAME AS master_book_chapters_folder as opposed to branch_book_chapters_folder
    # RENAME AS master_book_chapters_folder as opposed to branch_book_chapters_folder
    # Get the path to the folder that holds the master crypts for the
    # book specified in the parameter.
    # @param book_name [String] the name of the book in question
    # @return [String] string path to the master crypts folder for the book
    def self.master_crypts_folder( book_name )
      return File.join( master_book_folder( book_name ), Indices::CHAPTER_CRYPTS_FOLDER_NAME )
    end

    # Find the path to a chapter crypt text file for a book within master. We need
    # the book's name and the chapter file's content identifier to derive the path.
    #
    # @param book_name [String] the name of the book in question
    # @param content_id [String] the identifier of the chapter content
    # @return [File] path to the crypted content index file for book
    def self.master_crypts_filepath( book_name, content_id )
      return File.join( master_crypts_folder( book_name ), "#{Indices::CHAPTER_FILENAME_PREFIX}.#{content_id}.txt" )
    end

    # Get the path to the .git directory of a book within master
    # @param book_name [String] the name of the book in question
    # @return [File] path to the master crypts git path for the book
    def self.master_book_git_folder( book_name )
      return File.join( master_book_folder( book_name ),".git" )
    end

    # Get the path to the master indices file for the given book.
    #
    # @param book_name [String] the name of the book in question
    # @return [File] path to the master indices file for the given book
    def self.book_master_indices_filepath( book_name )
      return File.join( master_book_folder( book_name ), Indices::BOOK_MASTER_INDEX_FILENAME )
    end



    # The folder that holds all the data for a specific branch that
    # is specified in the parameter.
    #
    # @param branch_id [String] the id of the branch session
    # @return [File] folder path to the assets of a given branch
    def self.branch_folder( branch_id )
      return File.join( Indices::BRANCH_CRYPTS_FOLDER_PATH, "#{Indices::BRANCH_BOOKS_FOLDER_PREFIX}-#{branch_id}" )
    end

    # Within branch, get the path to the book's asset folder.
    # @param book_name [String] the name of the book in question
    # @param branch_id [String] the id of the branch session
    # @return [File] path (within branch) to the book's assets folder
    def self.branch_book_folder( book_name, branch_id )
      return File.join( branch_folder( branch_id ), book_name )
    end

    # Get the path to the branch indices file for the book and branch ID
    # specified in the parameters.
    #
    # @param book_name [String] the name of the book in question
    # @param branch_id [String] the identifier of the branch in question
    # @return [File] path to the branch indices file for the given branch
    def self.branch_indices_filepath( book_name, branch_id )
      return File.join( branch_book_folder( book_name, branch_id ), Indices::BOOK_BRANCH_INDEX_FILENAME )
    end

    # Return the path to the given book's chapter crypts within a specified branch.
    # @param book_name [String] the name of the book in question
    # @param branch_id [String] the id of the branch session
    # @return [File] path (within branch) to the book's chapter crypts folder
    def self.branch_crypts_folder( book_name, branch_id )
      return File.join( branch_book_folder( book_name, branch_id ), Indices::CHAPTER_CRYPTS_FOLDER_NAME )
    end

    # Find the path to a chapter crypt text file for a book within  a branch. We need
    # the book's name and the chapter file's content identifier to derive the path.
    #
    # @param book_name [String] the name of the book in question
    # @param content_id [String] the identifier of the chapter content
    # @return [File] path to the crypted chapter index file for branch book
    def self.branch_crypts_filepath( book_name, branch_id, content_id )
      return File.join( branch_crypts_folder( book_name, branch_id ), "#{Indices::CHAPTER_FILENAME_PREFIX}.#{content_id}.txt" )
    end


  end


end
