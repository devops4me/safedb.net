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
  # == The First Push
  #
  # The first push on a machine
  #
  # - writes and secures the private key
  # - creates an entry within ~/.ssh/config
  # - does a git init and sets the git remote
  #
  # Subsequent pushes will always
  #
  # - add and commit to the local repository
  # - push crypts to the remote repository
  # - record the commit reference in the safe database tracker file
  # - copy the database tracker file to the removable drive
  #
  class Push < Controller

    # After backing up local assets the <b>push use case</b> creates a remoe github
    # repository if necessary and initializes the master crypts as a git repository
    # if necessary and then adds, commits and pushes the crypts up to the github
    # remote for safe keeping.
    def execute()

      open_remote_backend_location()

      # @todo ------------------------------------------------------------ >>
      # @todo REFACTOR the below into lib/utils/keys/keypair.rb
      # @todo REFACTOR And create a utiliy class for bulk of file Writer functionality
      # @todo Methods in keypair should NOT know about the Indices constants
      # @todo Refactor name from [Indices] to [Constants]
      # @todo ------------------------------------------------------------ >>
      # @todo Method Names
      # @todo ------------------------------------------------------------ >>
      # @todo   (1) - Constants.write_private_key()
      # @todo ------------------------------------------------------------ >>

      private_key_path = File.join( Indices::SSH_DIRECTORY_PATH, @verse[ Indices::REMOTE_PRIVATE_KEY_KEYNAME ] )
      private_key_exists = File.file?( private_key_path )
      puts "private key found at #{private_key_path}" if private_key_exists

      unless private_key_exists

        puts "private key will be created at #{private_key_path}"
        file_writer = Write.new()
        file_writer.file_key = Indices::PRIVATE_KEY_DEFAULT_KEY_NAME
        file_writer.to_dir = Indices::SSH_DIRECTORY_PATH
        file_writer.flow()

        FileUtils.chmod( 0600, private_key_path, :verbose => true )

      end

      ssh_host_name = @verse[ Indices::REMOTE_MIRROR_SSH_HOST_KEYNAME ] 
      ssh_config_exists = File.file?( Indices::SSH_CONFIG_FILE_PATH )
      config_file_contents = File.read( Indices::SSH_CONFIG_FILE_PATH ) if ssh_config_exists
      ssh_config_written = ssh_config_exists && config_file_contents.include?( ssh_host_name )
      puts "ssh config for host #{ssh_host_name} has already been written" if ssh_config_written

      unless ssh_config_written

        puts "ssh config for host #{ssh_host_name} will be written"
        config_backup_path = File.join( Indices::SSH_DIRECTORY_PATH, "safe.clobbered.ssh.config-#{TimeStamp.yyjjj_hhmm_sst()}" )
        File.write( config_backup_path, config_file_contents ) if ssh_config_exists
        puts "previous ssh config is archived at #{config_backup_path}" if ssh_config_exists

        File.open( Indices::SSH_CONFIG_FILE_PATH, "a" ) do  |line|
          line.puts( "\n" )
          line.puts( "Host #{ ssh_host_name }" )
          line.puts( "HostName github.com" )
          line.puts( "User #{ @verse[ Indices::GITHUB_USERNAME_KEYNAME ] }" )
          line.puts( "IdentityFile #{ private_key_path }" )
          line.puts( "StrictHostKeyChecking no" )
        end

        puts "ssh config has been successfully written"

      end

      puts ""
      return

=begin
ssh -i ~/.ssh/safedb.code.private.key.pem -vT git@safedb.code
git clone https://github.com/devops4me/safedb.net safedb.net
git remote set-url --push origin git@safedb.code:devops4me/safedb.net.git
=end

      git_username = @verse[ Indices::GITHUB_USERNAME_KEYNAME ]
      git_reponame = @verse[ Indices::GITHUB_REPOSITORY_KEYNAME ]

      unless ssh_config_file contains git_reponame

        #write out the SSH private key
        # @todo change the write method to change the file permissions

# SAFE_PRIVATE_KEY_KEYNAME

      # @todo - Write the chunk of text into .ssh/config file (name is git_reponame)
      # @todo - the User is git_username
      # @todo - the IdentityFile is Dir.home() joined to .ssh and User is git_username

      user_host_name = "#{Etc.getlogin()}@#{Socket.gethostname()}"
      @verse.store( Indices::REMOTE_LAST_PUSH_ON, TimeStamp.readable() )
      @verse.store( Indices::REMOTE_LAST_PUSH_BY, user_host_name )

      end # end the unless block


# --  SAFE_REMOTE_SSH_HOST = "safe.remote"
# --  SAFE_REMOTE_HOST_NAME = "github.com"

  # @todo - link this to the Keys class to use the same string constant
# --  SAFE_PRIVATE_KEY_KEYNAME = "private.key"




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

Setting up passwordless git interactions (cloning, pulling, pushing) is the same as setting up passwordless ssh login.

To interact with Git without passwords you need to

- setup a public private SSH keypair
- install and lock down the private key
- create a SSH IdentityFile called config in `$HOME/.ssh/config`
- install the public key into BitBucket, GitLab, GitHub or a SSH accessible repo

### Setup Passwordless SSH

Passwordless SSH is a prerequisite to passwordless git interaction.

### The SSH Identity File

The Identity File is telling the SSH subsystem that when you see this particular hostname (IP Address) - you submit this private key because that host will for sure have the corresponding public key in its authorized keys cache.

When using Github, Gitlab or BitBucket - you go to a screen and enter in the public key portion.

```
Host bitbucket.server
StrictHostKeyChecking no
HostName bitbucket.org
User joebloggs276
IdentityFile /home/joebloggs/.ssh/bitbucket-repo-private-key.pem
```

### The Passwordless SSH Setup Commands

Our local user `joebloggs` has an account with `bitbucket.org` with username `joebloggs276` and has submitted the public key to it. He has created a private key at `/home/joebloggs/.ssh/bitbucket-repo-private-key.pem` (locked with a 400) and an identity file at `/home/joebloggs/.ssh/config`.

``` bash
ssh-keygen -t rsa                                              # enter /home/joebloggs/.ssh/bitbucket-repo-private-key.pem
chmod 400 /home/joebloggs/.ssh/bitbucket-repo-private-key.pem  # restrict to user read-only permissions
GIT_HOST_IP=bitbucket.org                                      # set the hostname as bitbucket.org
ssh-keyscan $GIT_HOST_IP >> /home/joebloggs/.ssh/known_hosts   # prevents a authenticity of host cant be established prompt
ssh -i /home/joebloggs/.ssh/bitbucket-repo-private-key.pem -vT "joebloggs276@$GIT_HOST_IP" # test that all will be okay
git clone git@bitbucket.org:joeltd/bigdata.git mirror.bigdata  # this clone against bigdata account and repo is bigdata
```

BITBUCKET_USER=joebloggs276;
# curl --user ${BITBUCKET_USER} https://api.bitbucket.org/2.0/repositories/joeltd
curl --user ${BITBUCKET_USER} git@api.bitbucket.org/2.0/repositories/joeltd


Note that the clone command uses the bitbucket account called joeltd and the repository is called big_data_scripts.

The response to the SSH test against a bitbucket repository for user

`ssh -i /home/joebloggs/.ssh/bitbucket-repo-private-key.pem -vT "joebloggs276@$GIT_HOST_IP"`

## Setup Git in Existing Directory

To hook up with a new repository from a directory with files you first

- create the remote repository (use safe's github and gitlab tooling)
- safe will have created a public / private keypair and installed it in the remote repo
- locally their should be a private key (with 0600 permissions) and an entry in ~/.ssh/config
- go to the git directory (without a .git folder)

The commands to run

git init
git add -A
git status
git commit -am "First checkin of project."
git remote add origin git@<<Host>>:<<userOrGroup>>/<<repo-name>>.git
git remote -v
git push --set-upstream origin master

=end


# @todo -- also see temp-git-code.rb class in this directory
# @todo -- also see temp-git-code.rb class in this directory
# @todo -- also see temp-git-code.rb class in this directory
# @todo -- also see temp-git-code.rb class in this directory
# @todo -- also see temp-git-code.rb class in this directory
# @todo -- also see temp-git-code.rb class in this directory
# @todo -- also see temp-git-code.rb class in this directory
# @todo -- also see temp-git-code.rb class in this directory
# @todo -- also see temp-git-code.rb class in this directory
# @todo -- also see temp-git-code.rb class in this directory


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



      return


    end


  end


end
