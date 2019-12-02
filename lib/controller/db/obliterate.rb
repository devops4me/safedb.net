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

            unless ( File.exist?( Indices::MASTER_CRYPTS_FOLDER_PATH ) && File.directory?( Indices::MASTER_CRYPTS_FOLDER_PATH ) )

                puts ""
                puts "  Could not find directory"
                puts "  #{Indices::MASTER_CRYPTS_FOLDER_PATH}"
                puts "  #{Indices::NOTHING_TO_OBLITERATE}"
                puts ""
                return

            end

            backup_folder_name = TimeStamp.yyjjj_hhmm_sst() + "-" + Indices::MASTER_CRYPTS_FOLDER_NAME
            backup_folder_path = File.join( Indices::BACKUP_CRYPTS_FOLDER_PATH, backup_folder_name )
            FileUtils.mkdir_p( backup_folder_path )
            FileUtils.cp_r( "#{Indices::MASTER_CRYPTS_FOLDER_PATH}/.", backup_folder_path )

            FileUtils.remove_dir( Indices::MASTER_CRYPTS_FOLDER_PATH ) if  ( File.exist?( Indices::MASTER_CRYPTS_FOLDER_PATH ) && File.directory?( Indices::MASTER_CRYPTS_FOLDER_PATH ) )
            FileUtils.remove_dir( Indices::BRANCH_CRYPTS_FOLDER_PATH ) if  ( File.exist?( Indices::BRANCH_CRYPTS_FOLDER_PATH ) && File.directory?( Indices::BRANCH_CRYPTS_FOLDER_PATH ) )
            FileUtils.remove_dir( Indices::BRANCH_INDICES_FOLDER_PATH ) if  ( File.exist?( Indices::BRANCH_INDICES_FOLDER_PATH ) && File.directory?( Indices::BRANCH_INDICES_FOLDER_PATH ) )

            puts ""
            puts "  The safe has been successfully obliterated."
            puts "  The obliterated safe database is backed up in this folder."
            puts "  #{backup_folder_path}"
            puts "  safe init   # this will create a new safe"
            puts "  safe pull   # downloads a remote safe db"
            puts ""

            return


        end


    end


end
