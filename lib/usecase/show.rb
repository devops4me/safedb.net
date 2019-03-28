#!/usr/bin/ruby

module SafeDb

  # Show the mini dictionary of key-value pairs within the logged in book
  # at the opened chapter and verse.
  #
  # If no dictionary exists at the opened chapter and verse a suitable
  # message is pushed out to the console.
  class Show < UseCase

    def execute

=begin
      return unless ops_key_exists?
      master_db = BookIndex.read()

      return if unopened_envelope?( master_db )

      chapter_id = ENVELOPE_KEY_PREFIX + master_db[ ENV_PATH ]
      has_chapter = KeyApi.db_envelope_exists?( master_db[ chapter_id ] )
      chapter_data = get_chapter_data( master_db[ chapter_id ] ) if has_chapter
      has_verse = has_chapter && chapter_data.has_key?( master_db[ KEY_PATH ] )

      return unless has_verse

      line_dictionary = chapter_data[ master_db[ KEY_PATH ] ]

      puts ""
      puts "### ##################################\n"
      puts "### chapter =>> #{master_db[ ENV_PATH ]}\n"
      puts "### & verse =>> #{master_db[ KEY_PATH ]}\n"
      puts "### # lines =>> #{line_dictionary.length}\n"
      puts "### ##################################\n"
      puts "--- ----------------------------------\n"
      puts ""
=end

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



      puts ""
      puts "### ##################################\n"
      puts "### chapter :=> #{@chapter_id}\n"
      puts "### & verse :=> #{@verse_id}\n"
      puts "### # lines :=> #{@verse_data.length}\n" unless @verse_data.nil?
      puts "### ##################################\n"
      puts "--- ----------------------------------\n"
      puts ""

      if @verse_data.nil?
        puts "There is no data in this chapter/verse."
        puts "Use the put command to add a key/value pair."
        puts ""
        puts "safe put name \"Joe Bloggs\""
        puts "safe put email joe@safedb.net"
        puts "safe show"
        puts ""
        return
      end

      showable_content = {}
      @verse_data.each do | key_str, value_object |

        is_file = key_str.start_with? FILE_KEY_PREFIX
        value_object.store( FILE_CONTENT_KEY, SECRET_MASK_STRING ) if is_file
        showable_content.store( key_str[ FILE_KEY_PREFIX.length .. -1 ], value_object ) if is_file
        next if is_file

        is_secret = key_str.start_with? "@"
        showable_val = SECRET_MASK_STRING if is_secret
        showable_val = value_object unless is_secret
        showable_content.store( key_str, showable_val )

      end

      puts JSON.pretty_generate( showable_content )
      puts "--- ----------------------------------\n"
      puts "### ##################################\n"
      puts ""

    end

    private

    SECRET_MASK_STRING = "***********************"

  end


end
