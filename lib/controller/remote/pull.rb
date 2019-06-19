#!/usr/bin/ruby
	
module SafeDb

  # If the removable drive path is configured and exists and contains the master
  # index file, the pull use case backs up both file and master crypts (if necessary)
  # and then refreshes them with the state that exists in the remote mirrored git
  # directory and the indices on the removable drive path.
  class Pull < Controller

    # If the removable drive path is configured and exists and contains the master
    # index file, the pull use case backs up both file and master crypts (if necessary)
    # and then refreshes them with the state that exists in the remote mirrored git
    # directory and the indices on the removable drive path.
    def execute()

      puts ""

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



=begin
      require "octokit"
############client = Octokit::Client.new(:login => 'defunkt', :password => 'c0d3b4ssssss!')

client = Octokit::Client.new(:access_token => '')
user = client.user
puts "Company Name => #{user[:company]}"
puts "User Name => #{user[:name]}"
puts "User ID => #{user[:id]}"
puts "Email => #{user[:email]}"
puts "Login => #{user[:login]}"
puts "Biography => #{user[:bio]}"
=end

      return


    end


  end


end
