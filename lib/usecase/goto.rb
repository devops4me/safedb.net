#!/usr/bin/ruby

module SafeDb

  # Goto is a shortcut (or alias even) for the open command that takes an integer
  # index that effectively specifies which <envelope> and <key> to open.
  #
  # Use <b>view</b> to list the valid integer indices for each envelope and key
  # combination.
  #
  # View maps out and numbers each envelope/key combination.
  # Goto with the number effectively shortcuts the open pin pointer command.
  # Show prints the dictionary at the opened path masking any secrets.
  #
  # Once goto is enacted all path CRUD commands come into play as if you had
  # opened the path. These include put, copy, paste, show, tell and delete.
  class Goto < UseCase

    # The index (number) starting with 1 of the envelope and key-path
    # combination that should be opened.
    attr_writer :index

    def execute

      return unless ops_key_exists?
      master_db = BookIndex.read()

      goto_location = 0
      envelope_dictionaries = KeyApi.to_matching_dictionary( master_db, ENVELOPE_KEY_PREFIX )
      envelope_dictionaries.each_pair do | envelope_name, crumb_dictionary |

        envelope_content = KeyStore.from_json( KeyApi.content_unlock( crumb_dictionary ) )
        envelope_content.each_key do | envelope_key |

          goto_location += 1
          next unless @index.to_i == goto_location

          open_uc = Open.new
          open_uc.env_path = envelope_name
          open_uc.key_path = envelope_key
          open_uc.flow_of_events

          return

        end


      end


    end


  end


end
