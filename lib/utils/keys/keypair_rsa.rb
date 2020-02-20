#!/usr/bin/ruby
# coding: utf-8

module SafeDb

  # This class creates and represents an Elliptic Curve cryptographic key.
  # The generated key can then be comsumed via its various aspects like its
  # ssh formatted public key and/or the pem formatted private key.
  class Keypair

######## ################################################################## #####################
######## ################################################################## #####################
######## KeyPair Creation with ssh_config SSH config file in .ssh Directory #####################
######## ################################################################## #####################
######## ################################################################## #####################

=begin


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

      git_username = @verse[ Indices::GIT_REPOSITORY_USER_KEYNAME ]
      git_reponame = @verse[ Indices::GIT_REPOSITORY_NAME_KEYNAME ]

      ssh_host_name = @verse[ Indices::REMOTE_MIRROR_SSH_HOST_KEYNAME ] 
      ssh_config_exists = File.file?( Indices::SSH_CONFIG_FILE_PATH )
      config_file_contents = File.read( Indices::SSH_CONFIG_FILE_PATH ) if ssh_config_exists
      ssh_config_written = ssh_config_exists && config_file_contents.include?( ssh_host_name )
      puts "ssh config for host #{ssh_host_name} has already been written" if ssh_config_written

      unless ssh_config_written

        puts "ssh config for host #{ssh_host_name} will be written"
        config_backup_path = File.join( Indices::SSH_DIRECTORY_PATH, "safe.clobbered.ssh.config-#{TimeStamp.yyjjj_hhmm_sst()}" )
        File.write( config_backup_path, config_file_contents ) if ssh_config_exists
        puts "original ssh config at #{config_backup_path}" if ssh_config_exists

        File.open( Indices::SSH_CONFIG_FILE_PATH, "a" ) do |line|
          line.puts( "\n" )
          line.puts( "Host #{ ssh_host_name }" )
          line.puts( "HostName github.com" )
          line.puts( "User #{ git_username }" )
          line.puts( "IdentityFile #{ private_key_path }" )
          line.puts( "StrictHostKeyChecking no" )
        end

        puts "ssh config has been successfully written"

      end

      puts ""

      ssh_test_cmd_string = "ssh -i #{private_key_path} -vT git@github.com"
      system( ssh_test_cmd_string )
      ssh_cmd_exit_status = $?.exitstatus

      unless ssh_cmd_exit_status == 1

        puts ""
        puts "The command exit status is #{ssh_test_exitstatus}"
        puts ""
        puts "### ##### : ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        puts "### Error : SSH test result did not contain expected string."
        puts "### Query : #{ ssh_test_cmd_string }"
        puts "### ##### : ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        puts ""

        return

      end

      puts ""
      puts "### ####### : ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      puts "### Success : The SSH connection test was a roaring success."
      puts "### Command : #{ ssh_test_cmd_string }"
      puts "### ####### : ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      puts ""

=end




######## ################################################################## #####################
######## ################################################################## #####################




    # Generate an elliptic curve cryptographic keypair. After the key is
    # generated, both the public and private keys can be retrieved through
    # the accessors.
    #
    def initialize

      @ec_keypair = OpenSSL::PKey::EC.new( Indices::ELLIPTIC_CURVE_KEY_TYPE )
      @ec_keypair.generate_key!

      log.info(x) { "An elliptic curve keypair has just been generated." }

    end


    # Get the private key aspect of this elliptic curve cryptographic key
    # in PEM format.
    # @return [String] the PEM formatted private key
    def private_key_pem()
      return @ec_keypair.to_pem()
    end


    # Get the public key aspect of this elliptic curve cryptographic key
    # in the long line SSH format. This format states the key type which
    # will be **ecdsa-sha2-nistp384** followed by base64 encoded data.
    #
    # The returned one line public key will likely contain forward slashes
    # and possibly equal signs at the end of the string.
    #
    # @return [String] the SSH formatted public key prefixed by the key type
    def public_key_ssh()
      require 'net/ssh'
      key_type = @ec_keypair.ssh_type()
      key_data = [ @ec_keypair.to_blob ].pack('m0')
      return "#{key_type} #{key_data}"
    end


  end


end
