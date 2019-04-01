#!/usr/bin/ruby

module SafeDb

  # View provides a bird's eye view of the domain's content and links well with
  # the <b>goto</b>, <b>show</b> and <b>tell</b> commands.
  #
  #     $ xxx view
  #     $ xxx goto 5   # shortcut for xxx open <<envelope_name>> <<key_name>>
  #     $ xxx show
  #     $ xxx tell
  #     $ xxx tell url
  #
  # View maps out and numbers each envelope/key combination.
  # Goto with the number effectively shortcuts the open pinpointer.
  # Show prints out the dictionary at the opened path but masks any secrets.
  # Tell without a parameter echoes the secret.
  # Tell with parameter echoes the value of the parameter key (eg url).
  #
  # Once goto is enacted all path CRUD commands come into play as if you had
  # opened the path. These include put, copy, paste, show, tell and delete.
  class View < UseCase

    def execute

      book_index = BookIndex.new()

      puts ""
      puts "@@   Book Birthday := #{KeyApi.to_db_create_date(master_db)}\n"
      puts "@@       Book Name := #{KeyApi.to_db_domain_name(master_db)}\n"
      puts "@@       Book (Id) := #{KeyApi.to_db_domain_id(master_db)}\n"
      puts "---\n"
      puts "@@  Opened Chapter := #{book_index.chapter_name()}\n" if book_index.has_open_chapter?()
      puts "@@  + Opened Verse := #{book_index.verse_name()}\n"   if book_index.has_open_verse?()
      puts "---\n"

      goto_location = 1
      envelope_dictionaries = KeyApi.to_matching_dictionary( master_db, ENVELOPE_KEY_PREFIX )
      envelope_dictionaries.each_pair do | envelope_name, crumb_dictionary |
        is_opened_chapter = envelope_name.eql?( open_envelope )
        envelope_content = KeyStore.from_json( Lock.content_unlock( crumb_dictionary ) )
        envelope_content.each_key do | envelope_key |
          is_opened_verse = envelope_key.eql?( open_key_path )
          is_open = is_opened_chapter && is_opened_verse
          openend = is_open ? " (( open location ))" : ""
          fixdint = format( "%02d", goto_location )
          goindex = is_open ? "" : "[#{fixdint}] "
          puts "--- --- --------------------------------------" if is_open
          puts "--- #{goindex}#{envelope_name} ~> #{envelope_key}#{openend}\n"
          puts "--- --- --------------------------------------" if is_open
          goto_location += 1
        end
      end

      puts ""

      return

    end


  end


end
