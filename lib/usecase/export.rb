#!/usr/bin/ruby

module SafeDb

  # Export one, some or all chapters, verses and lines within the logged in book.
  #
  # == Aspirational Feature
  #
  # The --print flag demands that the exported text goes to stdout otherwise it
  # will be placed in an aptly named file in  the present working directory.
  class Export < UseCase

    def execute

      return unless ops_key_exists?
      master_db = KeyApi.read_master_db()

      puts ""
      puts "### #############################################################\n"
      puts "### Book Birthday =>> #{KeyApi.to_db_create_date(master_db)}\n"
      puts "### The Book Name =>> #{KeyApi.to_db_domain_name(master_db)}\n"
      puts "### The Book (Id) =>> #{KeyApi.to_db_domain_id(master_db)}\n"
      puts "### #############################################################\n"
      puts "--- --------------------------------------------------------------\n"

      chapters = KeyApi.to_matching_dictionary( master_db, ENVELOPE_KEY_PREFIX )
      export_filename = "safedb.book-#{KeyApi.read_app_id()}-#{KeyNow.yyjjj_hhmm_ss_nanosec()}.json"
      export_filepath = File.join( Dir.pwd, export_filename )

      exported_struct = {}
      verse_count = 0

      chapters.each_pair do | chapter_name, crumb_dictionary |

        chapter_struct = KeyDb.from_json( KeyApi.content_unlock( crumb_dictionary ) )
        verse_count += chapter_struct.length
        exported_struct.store( chapter_name, chapter_struct )

      end

      File.write( export_filepath, JSON.pretty_generate( exported_struct ) )

      puts ""
      puts "Number of chapters exported >> #{chapters.length}"
      puts "Number of verses exported >> #{verse_count}"
      puts "The export filename is #{export_filename}"
      puts "The Present Working Directory is #{Dir.pwd}"
      puts ""

      puts "--- --------------------------------------------------------------\n"
      puts "### #############################################################\n"
      puts ""


    end


  end


end
