#!/usr/bin/ruby
	
module SafeDb

  # Any {UseCase} class wishing to edit a safe verse can make use of the functionality
  # in this parent by exposing an edit_verse() method.
  #
  # Classes extending this class will have access to
  #
  # - a <tt>@chapther_data</tt> **data** structure
  # - a <tt>@chapther_id</tt> **string** index
  # - a <tt>@has_chapter</tt> **boolean** indicator
  # - a <tt>@verse_data</tt> **data** structure
  # - a <tt>@verse_id</tt> **string** index
  # - a <tt>@has_verse</tt> **boolean** indicator
  #
  # After the edit method completes the amended chapter data structure will be encrypted
  # and streamed to a ciphertext file.
  class EditVerse < UseCase

    # Execute the act of putting a string key and string value pair into a
    # map at the chapter and verse location, overwriting if need be.
    def execute

      return unless ops_key_exists?
      master_db = BookIndex.read()
      return if unopened_envelope?( master_db )

      @chapter_id = ENVELOPE_KEY_PREFIX + master_db[ ENV_PATH ]
      @has_chapter = KeyApi.db_envelope_exists?( master_db[ @chapter_id ] )
      @chapter_data = KeyStore.from_json( Lock.content_unlock( master_db[ @chapter_id ] ) ) if @has_chapter
      @chapter_data = KeyStore.new() unless @has_chapter

      @verse_id = master_db[ KEY_PATH ]
      @has_verse = @has_chapter && @chapter_data.has_key?( @verse_id )
      @verse_data = @chapter_data[ @verse_id ] if @has_verse

############## ===========================================================
############## Do we need this? Probably Not.
############## Do we need this? Probably Not.
##############      master_db[ @chapter_id ] = {} unless @has_chapter
############## ===========================================================

      @chapter_data.create_entry( @verse_id, @secret_id, @secret_value )

      # This is the expected edit() method that will do and deliver
      # the intented core contracted value proposition.
      edit_verse()


      content_header = create_header()
      Lock.content_lock( master_db[ @chapter_id ], @chapter_data.to_json, content_header )
      BookIndex.write( content_header, master_db )
      Show.new.flow_of_events

    end


  end


end
