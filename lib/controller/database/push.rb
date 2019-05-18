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


FileUtils.chmod 0755, 'somecommand'
FileUtils.chmod 0644, %w(my.rb your.rb his.rb her.rb)
FileUtils.chmod 0755, '/usr/bin/ruby', :verbose => true


### read -d '' keytext << EOF

## Command that will eject the public key starting like this
## ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHA
ssh-keygen -f ec-private-key-file.pem -y

ecdsa_public_key_str = %x[ #{convert_cmd} ]

puts ""
puts "===================================================="
puts "ECDSA Public Key"
puts "===================================================="
puts ecdsa_public_key_str
puts "===================================================="



rsa_key = OpenSSL::PKey::RSA.new 2048

puts ""
puts "#############################"
puts "RSA 2048 Private Key"
puts "#############################"
puts rsa_key.to_pem

puts ""
puts "#############################"
puts "RSA 2048 Public Key"
puts "#############################"
puts rsa_key.public_key.to_pem


### OpenSSL::PKey::EC.send(:alias_method, :private?, :private_key?)

the_256_key = OpenSSL::PKey::EC.new('prime256v1').generate_key!

puts ""
puts "#####################################"
puts "ED25519 to Public Key then 2 PEM"
puts "#####################################"
ed_key = the_256_key.to_text
puts ed_key
puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
puts the_256_key.public_key.to_octet_string( :compressed )
puts "------------------------------------------------------------------------"
puts the_256_key.public_key.to_octet_string( :uncompressed )
puts "------------------------------------------------------------------------"
puts the_256_key.public_key.to_octet_string( :hybrid )
puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++="
puts the_256_key.public_key.to_bn()
puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++="
puts the_256_key.public_key.to_bn().to_s
puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++="
puts the_256_key.public_key.to_bn().to_s(0)
puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++="
puts the_256_key.public_key.to_bn().to_s(2)
puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++="
puts the_256_key.public_key.to_bn().to_s(10)
puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++="
puts the_256_key.public_key.to_bn().to_s(16)

#### puts the_256_key.public_key.to_text
###### puts the_256_key.public_key.to_pem



puts ""
puts "#############################"
puts "the 256 key"
puts "#############################"
puts the_256_key.to_pem()
puts ""

cipher = OpenSSL::Cipher.new 'AES-128-CBC'
pass_phrase = 'secret123'

key_secure = the_256_key.export( cipher, pass_phrase )
puts "The secure key is #{key_secure}"


public_key_hex = the_256_key.public_key.to_bn.to_s(16).downcase
public_key_64 = [[public_key_hex].pack("H*")].pack("m0")

github_public_key_64 = Base64.urlsafe_encode64(the_256_key.public_key.to_bn.to_s(2), padding: false)

puts "Hex public key is => #{public_key_hex}"
puts ""
puts ""
puts "GitHub Public Key is => ssh-ed25519 #{github_public_key_64}"
puts "Base64 public key is => ssh-ed25519 #{public_key_64}"

puts ""
the_384_key = OpenSSL::PKey::EC.new('secp384r1')
the_384_key.generate_key!

puts "#############################"
puts "the 384 key"
puts "#############################"
puts the_384_key.to_pem()
puts ""

github_384_public_key_64 = Base64.urlsafe_encode64(the_384_key.public_key.to_bn.to_s(2), padding: false)
puts "GitHub Public Key is => ssh-ed25519 #{github_384_public_key_64}"

########## puts "Bytes public key is => #{the_384_key.to_bytes()}"
#################  puts the_384_key.public_key().get_public_key()

puts ""
return 

ec_domain_key, ec_public = OpenSSL::PKey::EC.new('secp384r1'), OpenSSL::PKey::EC.new('secp384r1')
ec_domain_key.generate_key!
ec_public.public_key = ec_domain_key.public_key


public_key_hex = ec_domain_key.public_key.to_bn.to_s(16).downcase
puts "The public key HEX is #{public_key_hex}"
puts "The basic public key is #{ec_domain_key.public_key.to_pem()}"
return


puts "the public key is #{ec_domain_key.public_key.export()}"
puts "the public key is #{ec_domain_key.public_key.to_pem()}"
puts "the private key is #{ec_domain_key.private_key.export()}"
puts "the private key is #{ec_domain_key.private_key.to_pem()}"
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
