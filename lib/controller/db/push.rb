#!/usr/bin/ruby
	
module SafeDb

    # A safe push will save the state of the local safe database in a
    # backend location (currently only a Git repository).
    #
    # This class does not require the user to be logged into a book.
    # Naturally it expects safe remote --provision to have been
    # called which creates the remote backend and then sets the git
    # remote origin urls for fetch and push.
    class Push < Controller

        # Execute the business of pushing to a remote safe
        # backend repository.
        def execute()

            # Only required when git pulling on a machine for
            # the very first time. This is used to grab the
            # github access token and repository user and repository
            # name for creating the push origin url.
            # ----------------------------------------------------------
            # open_remote_backend_location()
            # ----------------------------------------------------------

            puts ""
            puts "Pushing safe commits to the backend repository."
            puts ""

            GitFlow.push( Indices::MASTER_CRYPTS_FOLDER_PATH )

            puts ""

        end

=begin
      removable_drive_path = xxx # ~~~~ read this from the --to variable
      removable_drive_file = File.join( removable_drive_path, Indices::MASTER_INDICES_FILE_NAME )
      removable_drive_file_exists = File.exist?( removable_drive_file ) && File.file?( removable_drive_file )

      puts "Removable Drive Location => #{removable_drive_path}"
      puts "Removable Drive Filepath => #{removable_drive_file}"

      if removable_drive_file_exists
        drive_filename = TimeStamp.yyjjj_hhmm_sst() + "-" + Indices::MASTER_INDICES_FILE_NAME
        drive_backup_filepath = File.join( removable_drive_path, drive_filename )
        File.write( drive_backup_filepath, File.read( removable_drive_file ) )
        puts "Backup of Clobbered File => #{drive_backup_filepath}"
      end

      is_git = File.exist?( Indices::MASTER_CRYPTS_GIT_PATH ) && File.directory?( Indices::MASTER_CRYPTS_GIT_PATH )

=end



    end


end
