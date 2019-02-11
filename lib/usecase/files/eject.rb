#!/usr/bin/ruby
	
module SafeDb

  # The <b>eject use case</b> writes (or overwrites) a file or files.
  # Files are always ejected into the present working directory. If an
  # overwrite is detected a backup is taken of the about to be clobbered
  # file.
  #
  # If a keyname is provided then only the file against that key is ejected.
  # No keyname will eject every file in the opened chapter and verse.
  class Eject < UseCase

    attr_writer :file_key

    # Files are always ejected into the present working directory and any
    # about to be clobbered files are backed up with a timestamp.
    #
    # If a keyname is provided then only the file against that key is ejected.
    # No keyname will eject every file in the opened chapter and verse.
    def execute

      return unless ops_key_exists?
      master_db = get_master_database()
      return if unopened_envelope?( master_db )
      chapter_id = ENVELOPE_KEY_PREFIX + master_db[ ENV_PATH ]
      verse_id = master_db[ KEY_PATH ]
      chapter_data = OpenKey::KeyDb.from_json( OpenKey::KeyApi.content_unlock( master_db[ chapter_id ] ) )

      base64_content = chapter_data[ verse_id ][ "#{FILE_KEY_PREFIX}#{@file_key}" ][ FILE_CONTENT_KEY ]
      simple_filename = chapter_data[ verse_id ][ "#{FILE_KEY_PREFIX}#{@file_key}" ][ FILE_NAME_KEY ]
      file_full_path = File.join( Dir.pwd, simple_filename )
      backup_filename = OpenKey::KeyNow.yyjjj_hhmm_sst() + "-" + simple_filename
      backup_file_path = File.join( Dir.pwd, backup_filename )
      will_clobber = File.file?( file_full_path )

      File.write( backup_file_path, File.read( file_full_path ) ) if will_clobber
      ::File.write( file_full_path, Base64.urlsafe_decode64( base64_content ) )

      puts ""
      puts "File successfully ejected from safe into current directory."
      puts ""
      puts "Clobbered File = #{backup_filename}" if will_clobber
      puts "Current Directory = #{Dir.pwd}"
      puts "Ejected Filename = #{simple_filename}"
      puts "Chapter and Verse = #{master_db[ENV_PATH]}:#{verse_id}"
      puts "Ejected File Key = #{@file_key}"
      puts ""

    end


  end


end
