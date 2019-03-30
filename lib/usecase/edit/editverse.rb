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

    # This parental behaviour sets up common ubiquitous chapter and verse data structures
    # and indices. It then calls the child's query_verse() behaviour and once that is complete
    # it encrypts and persists an (updated) BookIndex and the amended chapter.
    #
    # The streaming process also deletes the current (old) BookIndex and chapter crypts.
    def execute

      # Before calling the edit_verse() method we perform some
      # preparatory activities that check, validate and setup.
      read_verse()

=begin
      return unless ops_key_exists?
      master_db = BookIndex.read()
      return if unopened_envelope?( master_db )

      @chapter_id = ENVELOPE_KEY_PREFIX + master_db[ ENV_PATH ]
      @has_chapter = db_envelope_exists?( master_db[ @chapter_id ] )
      @chapter_data = Content.unlock_chapter( master_db[ @chapter_id ] ) if @has_chapter
      @chapter_data = KeyStore.new() unless @has_chapter

      @verse_id = master_db[ KEY_PATH ]
      @has_verse = @has_chapter && @chapter_data.has_key?( @verse_id )
      @verse_data = @chapter_data[ @verse_id ] if @has_verse
      master_db[ @chapter_id ] = {} unless @has_chapter
=end

      # This is the expected edit() method that will do and deliver
      # the intented core contracted value proposition.
      edit_verse()

      # Now encrypt the changed verse and then write it out to a
      # chapter crypt file whilst garbage collecting the now spurious
      # and superceded script.
      update_verse()


    end


  end


end
