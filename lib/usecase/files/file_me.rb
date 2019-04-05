#!/usr/bin/ruby
	
module SafeDb

  # The <b>file use case</b> pulls a file in from either an accessible filesystem
  # or from a remote http, https, git, S3, GoogleDrive and/or ssh source.
  #
  # The @file_url is the most common parameter given to this use case.
  class FileMe < UseCase

    attr_writer :file_key, :file_url

    # There are 3 maps involved in the implementation and they are all (or in part) retrieved and/or
    # created as necessary. They are
    #
    # - the current chapter as a map
    # - the current verse as a map
    # - the file's keyname as a map
    #
    # Once the maps have been found and/or created if necessary the file's keyname map is either
    # populated or amended with the following data.
    #
    # - filename | {UseCase::FILE_NAME_KEY} | the file's simple name
    # - content64 | {UseCase::FILE_CONTENT_KEY} | the file's base64 content
    def execute

      return unless ops_key_exists?
      master_db = KeyApi.read_master_db()
      return if unopened_envelope?( master_db )

      chapter_id = ENVELOPE_KEY_PREFIX + master_db[ ENV_PATH ]
      chapter_exists = KeyApi.db_envelope_exists?( master_db[ chapter_id ] )
      chapter_data = DataStore.from_json( Lock.content_unlock( master_db[ chapter_id ] ) ) if chapter_exists
      chapter_data = DataStore.new() unless chapter_exists

      content_hdr = create_header()
      master_db[ chapter_id ] = {} unless chapter_exists
      verse_id = master_db[ KEY_PATH ]

      file_full_path = ::File.absolute_path( @file_url )
      file_base_name = ::File.basename( file_full_path )
      file_content64 = Base64.urlsafe_encode64( ::File.read( file_full_path ) )

      log.info(x) { "Key name of the file to ingest => #{@file_key}" }
      log.info(x) { "Ingesting file at path => #{file_full_path}" }
      log.info(x) { "The name of the file to ingest is => #{file_base_name}" }
      log.info(x) { "Size of base64 file content => [#{file_content64.length}]" }

      chapter_data.create_map_entry( verse_id, "#{FILE_KEY_PREFIX}#{@file_key}", FILE_NAME_KEY, file_base_name )
      chapter_data.create_map_entry( verse_id, "#{FILE_KEY_PREFIX}#{@file_key}", FILE_CONTENT_KEY, file_content64 )

      Lock.content_lock( master_db[ chapter_id ], chapter_data.to_json, content_hdr )
      BookIndex.write( content_hdr, master_db )

      Show.new.flow_of_events

    end


    private


    # Perform pre-conditional validations in preparation to executing the main flow
    # of events for this use case. This method may throw the below exceptions.
    #
    # @raise [SafeDirNotConfigured] if the safe's url has not been configured
    # @raise [EmailAddrNotConfigured] if the email address has not been configured
    # @raise [StoreUrlNotConfigured] if the crypt store url is not configured
    def pre_validation


    end


  end


end
