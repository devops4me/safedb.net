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
  #
  # What does a safe push do?
  #
  # - it logs in to the book specified in the master indices
  # - it pays attention to the verse at the specified coordinates
  # - if need be it writes the private key and secures it
  # - if need be it creates an entry within ~/.ssh/config
  # - if need be it does a git init in the master crypts folder
  # - if need be it connects to the created remote repository
  # - it then adds to the commit set and pushes
  # - 
  # - 

=begin
safe login safe.ecosystem
safe open <<chapter>> <<verse>>
cd ~/.ssh
safe eject github.ssh.config
safe eject safedb.code.private.key
chmod 600 safedb.code.private.key
cd <<repositories-folder>>
ssh -i ~/.ssh/safedb.code.private.key.pem -vT git@safedb.code
git clone https://github.com/devops4me/safedb.net safedb.net
git remote set-url --push origin git@safedb.code:devops4me/safedb.net.git
=end

  SAFE_REMOTE_SSH_HOST = "safe.remote"
  SAFE_REMOTE_HOST_NAME = "github.com"

  # @todo - link this to the Keys class to use the same string constant
  SAFE_PRIVATE_KEY_KEYNAME = "private.key"

Host safedb.crypt
HostName github.com
User devops4me
IdentityFile ~/.ssh/safedb.crypt.private.key.pem
StrictHostKeyChecking no


  # - 
  #
  class Push < Controller

    # After backing up local assets the <b>push use case</b> creates a remoe github
    # repository if necessary and initializes the master crypts as a git repository
    # if necessary and then adds, commits and pushes the crypts up to the github
    # remote for safe keeping.
    def execute()

      initialize_remote_store()

      git_username = @verse[ Indices::GITHUB_USERNAME_KEYNAME ]
      git_reponame = @verse[ Indices::GITHUB_REPOSITORY_KEYNAME ]

      unless ssh_config_file contains git_reponame

        #write out the SSH private key
        # @todo change the write method to change the file permissions
      file_writer = Write.new()
      file_writer.file_key = SAFE_PRIVATE_KEY_KEYNAME
      file_writer.to_dir = File.join( Dir.home(), ".ssh" )
      file_writer.query_verse()
SAFE_PRIVATE_KEY_KEYNAME

      # @todo - Write the chunk of text into .ssh/config file (name is git_reponame)
      # @todo - the User is git_username
      # @todo - the IdentityFile is Dir.home() joined to .ssh and User is git_username

      user_host_name = "#{Etc.getlogin()}@#{Socket.gethostname()}"
      @verse.store( Indices::REMOTE_LAST_PUSH_ON, TimeStamp.readable() )
      @verse.store( Indices::REMOTE_LAST_PUSH_BY, user_host_name )

      end # end the unless block

      # Do a git init if no .git folder found
      # do git local config (for name and email) if necessary
      # do git set remote url add
      # do git add
      # do git commit
      # do git push origin master

#      @verse.store( Indices::REMOTE_LAST_PUSH_ID,  )
   # @todo set git remote url (for push) in the @verse
   # @todo set git clone url in the @verse
   # @todo set git commit id in the @verse
      
#   @todo now set the git clone url and commit ID in the master index file

      # Make sure git pull --from=/path/to/dir LOGS in and writes the /path/to/dir with KEY as the User@hostname

      ## Now the git push --to=/path/to/this/dir => IF no path read from @verse
      ## If no verse with user@host path the WRITE to present working directory


=begin
FileUtils.chmod 0755, 'somecommand'
FileUtils.chmod 0644, %w(my.rb your.rb his.rb her.rb)
FileUtils.chmod 0755, '/usr/bin/ruby', :verbose => true


### read -d '' keytext << EOF

## Command that will eject the public key starting like this
## ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHA
ssh-keygen -f ec-private-key-file.pem -y

ecdsa_public_key_str = %x[ #{convert_cmd} ]
=end

puts ""
the_384_key = OpenSSL::PKey::EC.new('secp384r1')
the_384_key.generate_key!

puts "#############################"
puts "the 384 key"
puts "#############################"
puts the_384_key.private_key.to_pem()
puts "#############################"
puts the_384_key.private_key.export()
puts "#############################"
puts the_384_key.public_key.export()
puts "#############################"
puts the_384_key.public_key.to_pem()
puts "#############################"
puts the_384_key.to_pem()
puts "#############################"
puts the_384_key.to_text()
puts ""

ec_private_key_encoded = Base64.urlsafe_encode64( the_384_key.to_pem() )

puts "Private Key Encoded"
puts "ec_private_key_encoded"
puts ""
return 

return
      puts ""

      drive_config = DataMap.new( Indices::MACHINE_CONFIG_FILEPATH )
      drive_config.use( Indices::MACHINE_CONFIG_SECTION_NAME )

      removable_drive_path = drive_config.get( Indices::MACHINE_REMOVABLE_DRIVE_PATH )
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



      return


    end


  end


end
