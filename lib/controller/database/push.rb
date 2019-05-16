#!/usr/bin/ruby
	
module SafeDb

  # After backing up local assets the <b>push use case</b> creates a remoe github
  # repository if necessary and initializes the master crypts as a git repository
  # if necessary and then adds, commits and pushes the crypts up to the github
  # remote for safe keeping.
  #
  # We also remember the commit reference and we add this to the master indices
  # file before finally backing up, and then updating the master indices file on
  # the locally accessible removable drive.
  class Push < Controller

    # After backing up local assets the <b>push use case</b> creates a remoe github
    # repository if necessary and initializes the master crypts as a git repository
    # if necessary and then adds, commits and pushes the crypts up to the github
    # remote for safe keeping.
    def execute()

      puts ""

      removable_drive_path = DataMap.new( Indices::MACHINE_CONFIG_FILEPATH ).use( Indices::MACHINE_CONFIG_SECTION_NAME ).get( Indices::MACHINE_REMOVABLE_DRIVE_PATH )

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
      FileUtils.copy_entry( Indices::MASTER_CRYPTS_FOLDER_PATH,  )


      puts "Backup of Clobbered Crypts => #{clobbered_crypts_path}"


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

  return


    end


  end


end
