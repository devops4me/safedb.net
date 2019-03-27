#!/usr/bin/ruby

module SafeDb

  # Show the mini dictionary of key-value pairs within the logged in book
  # at the opened chapter and verse.
  #
  # If no dictionary exists at the opened chapter and verse a suitable
  # message is pushed out to the console.
  class Show < UseCase

    def get_chapter_data( chapter_key )
      return KeyStore.from_json( Lock.content_unlock( chapter_key ) )
    end

    def execute

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

      showable_content = {}
      line_dictionary.each do | key_str, value_object |

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
