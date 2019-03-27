#!/usr/bin/ruby
	
module SafeDb

  class Print < UseCase

    attr_writer :key_name

    def get_chapter_data( chapter_key )
      return KeyStore.from_json( Lock.content_unlock( chapter_key ) )
    end

    def execute

      return unless ops_key_exists?

      master_db = get_master_database()

      return if unopened_envelope?( master_db )

      chapter_id = ENVELOPE_KEY_PREFIX + master_db[ ENV_PATH ]
      has_chapter = KeyApi.db_envelope_exists?( master_db[ chapter_id ] )

      chapter_data = get_chapter_data( master_db[ chapter_id ] ) if has_chapter
      has_verse = has_chapter && chapter_data.has_key?( master_db[ KEY_PATH ] )

      chapter_err_msg = "Nothing was found at chapter " + master_db[ ENV_PATH ]
      raise ArgumentError, chapter_err_msg unless has_chapter
      verse_err_msg = "Nothing was found at chapter " + master_db[ ENV_PATH ] + " verse " + master_db[ KEY_PATH ]
      raise ArgumentError, verse_err_msg unless has_verse

      print chapter_data[ master_db[ KEY_PATH ] ][ @key_name ]

    end


  end


end
