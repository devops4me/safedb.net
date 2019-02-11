#!/usr/bin/ruby
	
module SafeDb

  class Verse < UseCase

    def execute

      return unless ops_key_exists?
      master_db = get_master_database()
      return if unopened_envelope?( master_db )
      print master_db[ KEY_PATH ]

    end


  end


end
