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
  # - do a git init and set the git remote
  #
  # Subsequent pushes will always
  #
  # - add and commit to the local repository
  # - push crypts to the remote repository
  # - record the commit reference in the safe database tracker file
  # - copy the database tracker file to the removable drive

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

=begin
Host safedb.crypt
HostName github.com
User devops4me
IdentityFile ~/.ssh/safedb.crypt.private.key.pem
StrictHostKeyChecking no
=end

  # - 
  #
  class Push < Controller

    # After backing up local assets the <b>push use case</b> creates a remoe github
    # repository if necessary and initializes the master crypts as a git repository
    # if necessary and then adds, commits and pushes the crypts up to the github
    # remote for safe keeping.
    def execute()

      open_remote_backend_location()

      git_username = @verse[ Indices::GITHUB_USERNAME_KEYNAME ]
      git_reponame = @verse[ Indices::GITHUB_REPOSITORY_KEYNAME ]

      puts ""
      return

      unless ssh_config_file contains git_reponame

        #write out the SSH private key
        # @todo change the write method to change the file permissions
      file_writer = Write.new()
      file_writer.file_key = SAFE_PRIVATE_KEY_KEYNAME
      file_writer.to_dir = File.join( Dir.home(), ".ssh" )
      file_writer.query_verse()

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
FileUtils.chmod 0755, 'somecommand'
FileUtils.chmod 0644, %w(my.rb your.rb his.rb her.rb)
FileUtils.chmod 0755, '/usr/bin/ruby', :verbose => true


### read -d '' keytext << EOF

## Command that will eject the public key starting like this
## ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHA
ssh-keygen -f ec-private-key-file.pem -y

ecdsa_public_key_str = %x[ #{convert_cmd} ]
=end




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
