#!/usr/bin/ruby
	
module SafeDb

  # The <b>write use case</b> writes (or overwrites) a file at the
  # out url destination.
  class Write < UseCase

    attr_writer :file_url

    # The <b>read use case</b> pulls a file in from either an accessible filesystem
    # or from a remote http, https, git, S3, GoogleDrive and/or ssh source.
    def execute

      return unless ops_key_exists?
      master_db = get_master_database()
      return if unopened_envelope?( master_db )

      # Get the open chapter identifier (id).
      # Decide whether chapter already exists.
      # Then get (or instantiate) the chapter's hash data structure
      chapter_id = ENVELOPE_KEY_PREFIX + master_db[ ENV_PATH ]
      verse_id = master_db[ KEY_PATH ]
      chapter_exists = KeyApi.db_envelope_exists?( master_db[ chapter_id ] )


      # @todo begin
      # Throw an exception (error) if the chapter
      # either exists and is empty or does not exist.
      # @todo end


      # Unlock the chapter data structure by supplying
      # key/value mini-dictionary breadcrumbs sitting
      # within the master database at the section labelled
      # envelope@<<actual_chapter_id>>.
      chapter_data = KeyStore.from_json( Lock.content_unlock( master_db[ chapter_id ] ) )


      # Unlock the file content by supplying the
      # key/value mini-dictionary breadcrumbs sitting
      # within the chapter's data structure in the
      # section labelled <<verse_id>>.
      file_content = Lock.content_unlock( chapter_data[ verse_id ] )


      # We read the location url we plan to eject the
      # file out into.
      file_path = @file_url ? @file_url : chapter_data[ verse_id ][ "@out.url" ]
      file_name = ::File.basename( file_path)

      # If the directory the file will be exported to does
      # not exist we promptly create it.
      FileUtils.mkdir_p( File.dirname( file_path ) )

      # Create a backup file if we can detect that a
      # file occupies the eject (write) filepath.
      backup_file_path = ::File.join( ::File.dirname( file_path ), KeyNow.yyjjj_hhmm_sst() + "-" + file_name )
      ::File.write( backup_file_path, ::File.read( file_path ) ) if ::File.file?( file_path )


      # Now write (and if necessary overwrite) the eject
      # file url path with the previously ingested content.
      ::File.write( file_path, file_content )


      # Communicate that the indicated file has just been
      # successfully written out from the safe.
      print_file_success( master_db[ ENV_PATH ], verse_id, file_path )

    end


    private


    # Document a successful write of a file cocooned in the safe.
    # @param chapter_id the chapter of the file written out
    # @param verse_id the verse of the file written out
    # @param file_url the filepath the file was written to
    def print_file_success chapter_id, verse_id, file_url
      puts "File [#{file_url}] written out of safe at chapter [#{chapter_id}] and verse [#{verse_id}]."
    end


  end


end
