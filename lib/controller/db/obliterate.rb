#!/usr/bin/ruby
	
module SafeDb

    # Obliterate the entire safe database by removing a number of folders. This is a
    # drastic action especially as it will terminate all safe sessions on the machine
    # no matter which shell is being used.
    #
    # This action is recoverable in two ways. The first is a "safe pull" if using a
    # remote repository like git. The second is manual restoration of the obliterated
    # folder which is saved in the safedb-backup-crypts folder.
    class Obliterate < Controller

        # Print message and return if the master crypts directory does not exist. Otherwise
        # make a backup of the folder then obliterate
        # - the master crypts folder
        # - the branch crypts folder
        # - the branch keys folder
        def execute()

            puts ""

            unless ( File.exist?( Indices::MASTER_CRYPTS_FOLDER_PATH ) && File.directory?( Indices::MASTER_CRYPTS_FOLDER_PATH ) )

                puts "Could not find directory @ #{Indices::MASTER_CRYPTS_FOLDER_PATH}"
                puts "Therefore there is nothing to obliterate."
                puts ""
                return

            end

            backup_folder_name = TimeStamp.yyjjj_hhmm_sst() + "-" + Indices::MASTER_CRYPTS_FOLDER_NAME
            backup_folder_path = File.join( Indices::BACKUP_CRYPTS_FOLDER_PATH, backup_folder_name )
            FileUtils.mkdir_p( backup_folder_path )
            FileUtils.cp_r( "#{Indices::MASTER_CRYPTS_FOLDER_PATH}/.", backup_folder_path, verbose: true )

            puts "The obliterated safe is backed up @ #{backup_folder_path}"
            puts "xxxxxxxxxxx xxxxxxxxxx xxxx"
            puts ""


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

      clobbered_crypts_name = TimeStamp.yyjjj_hhmm_sst() + "-" + Indices::MASTER_CRYPTS_FOLDER_NAME
      clobbered_crypts_path = File.join( Indices::SAFE_DATABASE_FOLDER, clobbered_crypts_name )

      FileUtils.mkdir_p( clobbered_crypts_path )
      FileUtils.copy_entry( Indices::MASTER_CRYPTS_FOLDER_PATH, clobbered_crypts_path )


      puts "Backup of Clobbered Crypts => #{clobbered_crypts_path}"

      is_git = File.exist?( Indices::MASTER_CRYPTS_GIT_PATH ) && File.directory?( Indices::MASTER_CRYPTS_GIT_PATH )
=end


            return


        end


    end


end
