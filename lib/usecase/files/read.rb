#!/usr/bin/ruby
	
module SafeDb

  # The <b>read use case</b> pulls a file in from either an accessible filesystem.
  #
  # This use case expects a @file_url parameter.
  class Read < EditVerse

    attr_writer :file_key, :file_url

    # The <b>read use case</b> pulls a file in from an accessible filesystem.
    def edit_verse()

      file_full_path = ::File.absolute_path( @file_url )
      file_base_name = ::File.basename( file_full_path )
      file_content64 = Base64.urlsafe_encode64( ::File.read( file_full_path ) )

      log.info(x) { "Key name of the file to ingest => #{@file_key}" }
      log.info(x) { "Ingesting file at path => #{file_full_path}" }
      log.info(x) { "The name of the file to ingest is => #{file_base_name}" }
      log.info(x) { "Size of base64 file content => [#{file_content64.length}]" }

      filedata_map = {}
      filedata_map.store( Indices::INGESTED_FILE_BASE_NAME_KEY, file_base_name )
      filedata_map.store( Indices::INGESTED_FILE_CONTENT64_KEY, file_content64 )

      @verse.store( Indices::INGESTED_FILE_LINE_NAME_KEY + @file_key, filedata_map )

    end


  end


end
