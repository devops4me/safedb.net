#!/usr/bin/ruby
	
module SafeDb

  # The <b>write use case</b> writes (or overwrites) a file or files.
  # Files are always ejected into the present working directory. If an
  # overwrite is detected a backup is taken of the about to be clobbered
  # file.
  #
  # If a keyname is provided then only the file against that key is ejected.
  # No keyname will eject every file in the opened chapter and verse.
  #
  # Whenever .pem files are written out, the file permissions are changed
  # to 0600 (only read/write for the owner).
  class Write < QueryVerse

    # The line name within the verse denoting the file to write out.
    attr_writer :linekey

    # This parameter is currently examined as a folder path only. Do not send
    # a filepath paramter against the --to option.
    # Also do not use squiggle (like ~/.ssh) within the --to parameter.
    attr_writer :folder

    # Use the chapter and verse setup to read the parameter {@key_name}
    # and print its corresponding value without a line feed or return.
    def query_verse()

      bcv_name = "#{@book.book_name()}/#{@book.get_open_chapter_name()}/#{@book.get_open_verse_name()}"

      puts ""
      puts "#{bcv_name} (#{@verse.length()})\n"

      base64_content = @verse[ Indices::INGESTED_FILE_LINE_NAME_KEY + @linekey ][ Indices::INGESTED_FILE_CONTENT64_KEY ]
      simple_filename = @verse[ Indices::INGESTED_FILE_LINE_NAME_KEY + @linekey ][ Indices::INGESTED_FILE_BASE_NAME_KEY ]

      # Do a mkdir_p if @folder has some valid non-whitespace text
      # If so check that we have permissions to write to the specified folder
      destination_dir = Dir.pwd if @folder.nil?
      destination_dir = @folder unless @folder.nil?

      file_full_path = File.join( destination_dir, simple_filename )
      backup_filename = TimeStamp.yyjjj_hhmm_sst() + "-" + simple_filename
      backup_file_path = File.join( destination_dir, backup_filename )
      will_clobber = File.file?( file_full_path )

      puts ""
      puts "Clobbered File = #{backup_filename}" if will_clobber
      puts "Prescribed Directory = #{@folder}" unless @folder.nil?
      puts "Present Directory = #{Dir.pwd}" if @folder.nil?
      puts "Written Out Filename = #{simple_filename}"
      puts "The Full Filepath = #{file_full_path}"
      puts "Safe File Key Name = #{@linekey}"
      puts ""

      File.write( backup_file_path, File.read( file_full_path ) ) if will_clobber
      ::File.write( file_full_path, Base64.urlsafe_decode64( base64_content ) )

      is_pem_file = simple_filename.end_with? "\.pem"

      puts "ssh .pem file detected so setting 0600 permissions" if is_pem_file
      FileUtils.chmod( 0600, file_full_path, :verbose => true ) if is_pem_file

      puts "File successfully written from safe to filesystem."
      puts ""

    end


  end


end
