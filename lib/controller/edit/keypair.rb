#!/usr/bin/ruby
	
module SafeDb

  # The default action of the <b>keypair use case</b> is to create a private and
  # public keypair and store them within the open chapter and verse.
  #
  # The keypair name parameter is used as a prefix to compose the private and
  # public key keynames.
  #
  # Currently the only algorithm used is the super secure EC (eliptic curve)
  # with 384 bits.
  class Keypair < EditVerse

    # The <b>keypair use case</b> creates a private and public keypair and stores
    # them within the open chapter and verse.
    def execute()

      attr_writer :keypair_name

      the_key = OpenSSL::PKey::EC.new('secp384r1')
      the_key.generate_key!

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

puts "#############################"
puts "the 384 key"
puts "#############################"
puts the_key.private_key.to_pem()
puts "#############################"
puts the_key.private_key.export()
puts "#############################"
puts the_key.public_key.export()
puts "#############################"
puts the_key.public_key.to_pem()
puts "#############################"
puts the_key.to_pem()
puts "#############################"
puts the_key.to_text()
puts ""

ec_private_key_encoded = Base64.urlsafe_encode64( the_key.to_pem() )

puts "Private Key Encoded"
puts "#{ec_private_key_encoded}"
puts ""
return 

=begin
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
=end

    end


  end


end
