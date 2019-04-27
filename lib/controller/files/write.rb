#!/usr/bin/ruby
	
module SafeDb

  # The <b>write use case</b> writes (or overwrites) a file or files.
  # Files are always ejected into the present working directory. If an
  # overwrite is detected a backup is taken of the about to be clobbered
  # file.
  #
  # If a keyname is provided then only the file against that key is ejected.
  # No keyname will eject every file in the opened chapter and verse.
  class Write < QueryVerse

    attr_writer :file_key, :to_dir

    # Use the chapter and verse setup to read the parameter {@key_name}
    # and print its corresponding value without a line feed or return.
    def query_verse()

      bcv_name = "#{@book.book_name()}/#{@book.get_open_chapter_name()}/#{@book.get_open_verse_name()}"

      puts ""
      puts "book/chapter/verse\n"
      puts "#{bcv_name} (#{@verse.length()})\n"

      base64_content = @verse[ Indices::INGESTED_FILE_LINE_NAME_KEY + @file_key ][ Indices::INGESTED_FILE_CONTENT64_KEY ]
      simple_filename = @verse[ Indices::INGESTED_FILE_LINE_NAME_KEY + @file_key ][ Indices::INGESTED_FILE_BASE_NAME_KEY ]

      # Do a mkdir_p if @to_dir has some valid non-whitespace text
      # If so check that we have permissions to write to the specified folder
      destination_dir = Dir.pwd if @to_dir.nil?
      destination_dir = @to_dir unless @to_dir.nil?

      file_full_path = File.join( destination_dir, simple_filename )
      backup_filename = TimeStamp.yyjjj_hhmm_sst() + "-" + simple_filename
      backup_file_path = File.join( destination_dir, backup_filename )
      will_clobber = File.file?( file_full_path )

      puts ""
      puts "Clobbered File = #{backup_filename}" if will_clobber
      puts "Prescribed Directory = #{@to_dir}" unless @to_dir.nil?
      puts "Present Directory = #{Dir.pwd}" if @to_dir.nil?
      puts "Written Out Filename = #{simple_filename}"
      puts "The Full Filepath = #{file_full_path}"
      puts "Written File Key = #{@file_key}"
      puts ""
      puts "File successfully written from safe to filesystem."
      puts ""

      File.write( backup_file_path, File.read( file_full_path ) ) if will_clobber
      ::File.write( file_full_path, Base64.urlsafe_decode64( base64_content ) )

    end


  end


end
