#!/usr/bin/ruby

module SafeDb

  class KeyApi

    # Return a date/time string detailing when the master database was first created.
    #
    # @param the_master_db [Hash]
    #    the master database to inspect = REFACTOR convert methods into a class instance
    #
    # @return [String]
    #    return a date/time string representation denoting when the master database
    #    was first created.
    def self.to_db_create_date( the_master_db )
      return the_master_db[ DB_CREATE_DATE ]
    end


    # Return the domain name of the master database.
    #
    # @param the_master_db [Hash]
    #    the master database to inspect = REFACTOR convert methods into a class instance
    #
    # @return [String]
    #    return the domain name of the master database.
    def self.to_db_domain_name( the_master_db )
      return the_master_db[ DB_DOMAIN_NAME ]
    end


    # Return the domain ID of the master database.
    #
    # @param the_master_db [Hash]
    #    the master database to inspect = REFACTOR convert methods into a class instance
    #
    # @return [String]
    #    return the domain ID of the master database.
    def self.to_db_domain_id( the_master_db )
      return the_master_db[ DB_DOMAIN_ID ]
    end


    # Return a dictionary containing a string key and the corresponding master database
    # value whenever the master database key starts with the parameter string.
    #
    # For example if the master database contains a dictionary like this.
    #
    #      envelope@earth => { radius => 24034km, sun_distance_light_minutes => 8 }
    #      textfile@kepler => { filepath => $HOME/keplers_laws.txt, filekey => Nsf8F34dhDT34jLKsLf52 }
    #      envelope@jupiter => { radius => 852837km, sun_distance_light_minutes => 6 }
    #      envelope@pluto => { radius => 2601km, sun_distance_light_minutes => 52 }
    #      textfile@newton => { filepath => $HOME/newtons_laws.txt, filekey => sdDFRTTYu4567fghFG5Jl }
    #
    # with "envelope@" as the start string to match.
    # The returned dictionary would have 3 elements whose keys are the unique portion of the string.
    #
    #      earth => { radius => 24034km, sun_distance_light_minutes => 8 }
    #      jupiter => { radius => 852837km, sun_distance_light_minutes => 6 }
    #      pluto => { radius => 2601km, sun_distance_light_minutes => 52 }
    #
    # If no matches are found an empty dictionary is returned.
    #
    # @param the_master_db [Hash]
    #    the master database to inspect = REFACTOR convert methods into a class instance
    #
    # @param start_string [String]
    #    the start string to match. Every key in the master database that
    #    starts with this string is considered a match. The corresponding value
    #    of each matching key is appended onto the end of an array.
    #
    # @return [Hash]
    #    a dictionary whose keys are the unique (2nd) portion of the string with corresponding
    #    values and in no particular order.
    def self.to_matching_dictionary( the_master_db, start_string )

      matching_dictionary = {}
      the_master_db.each_key do | db_key |
        next unless db_key.start_with?( start_string )
        dictionary_key = db_key.gsub( start_string, "" )
        matching_dictionary.store( dictionary_key, the_master_db[db_key] )
      end
      return matching_dictionary

    end


  end


end
