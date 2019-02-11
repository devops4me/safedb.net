#!/usr/bin/ruby
	
module SafeDb

  # The <b>delete use case</b> delete's one or more of the safe's entities.
  #
  # - at <tt>verse</tt> level - it can delete one or more lines
  # - at <tt>chapter</tt> level - it can delete one or more verses
  # - at <tt>book</tt> level - it can delete one or more chapters
  # - at <tt>safe</tt> level - it can delete one book
  #
  class DeleteMe < UseCase

    attr_writer :entity_id

    # Deletion that currently expects an open chapter and verse and always
    # wants to delete only one line (key/value pair).
    def execute

      return unless ops_key_exists?
      master_db = OpenKey::KeyApi.read_master_db()
      return if unopened_envelope?( master_db )

      chapter_id = ENVELOPE_KEY_PREFIX + master_db[ ENV_PATH ]
      chapter_exists = OpenKey::KeyApi.db_envelope_exists?( master_db[ chapter_id ] )
      chapter_data = OpenKey::KeyDb.from_json( OpenKey::KeyApi.content_unlock( master_db[ chapter_id ] ) ) if chapter_exists
      chapter_data = OpenKey::KeyDb.new() unless chapter_exists

      content_hdr = create_header()
      master_db[ chapter_id ] = {} unless chapter_exists
      verse_id = master_db[ KEY_PATH ]

      chapter_data.delete_entry( verse_id, @entity_id )
      chapter_data.delete_entry( verse_id, "#{FILE_KEY_PREFIX}#{@entity_id}" )

      OpenKey::KeyApi.content_lock( master_db[ chapter_id ], chapter_data.to_json, content_hdr )
      OpenKey::KeyApi.write_master_db( content_hdr, master_db )
      Show.new.flow_of_events

    end


  end


end
