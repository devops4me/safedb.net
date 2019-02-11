#!/usr/bin/ruby

module SafeDb

  # Export the entire book if no chapter and verse is specified (achieved with a safe close),
  # or the chapter if only the chapter is open (safe shut or safe open <<chapter>>, or the
  # mini-dictionary at the verse if both chapter and verse are open.
  class Export < UseCase

    def get_chapter_data( chapter_key )
      return KeyDb.from_json( KeyApi.content_unlock( chapter_key ) )
    end

    def execute

      return unless ops_key_exists?
      master_db = KeyApi.read_master_db()

      return if unopened_envelope?( master_db )

      chapter_id = ENVELOPE_KEY_PREFIX + master_db[ ENV_PATH ]
      has_chapter = KeyApi.db_envelope_exists?( master_db[ chapter_id ] )

      unless has_chapter
        puts "{}"
        return
      end

      chapter_data = get_chapter_data( master_db[ chapter_id ] )
      puts JSON.pretty_generate( chapter_data )

      return

    end


  end


end
