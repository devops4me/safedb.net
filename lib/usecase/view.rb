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

      return unless ops_key_exists?
      master_db = BookIndex.read()

      open_envelope = "(none)" if master_db[ ENV_PATH ].nil?
      open_envelope = master_db[ ENV_PATH ] unless master_db[ ENV_PATH ].nil?
      open_key_path = "(none)" if master_db[ KEY_PATH ].nil?
      open_key_path = master_db[ KEY_PATH ] unless master_db[ KEY_PATH ].nil?

      puts ""
##      puts "--- Book Birthday ~> #{KeyApi.to_db_create_date(master_db)}\n"
##      puts "--- The Book Name ~> #{KeyApi.to_db_domain_name(master_db)}\n"
##      puts "--- The Book (Id) ~> #{KeyApi.to_db_domain_id(master_db)}\n"
      puts "---\n"
      puts "--- Chapter ~> #{open_envelope}\n"
      puts "--- + Verse ~> #{open_key_path}\n"
      puts "---\n"

      goto_location = 1
      envelope_dictionaries = KeyApi.to_matching_dictionary( master_db, ENVELOPE_KEY_PREFIX )
      envelope_dictionaries.each_pair do | envelope_name, crumb_dictionary |
        is_opened_chapter = envelope_name.eql?( open_envelope )
        envelope_content = KeyStore.from_json( KeyApi.content_unlock( crumb_dictionary ) )
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
