#!/usr/bin/ruby

module SafeDb

  # The shell session can access the 152 characters of crypt and salt text
  # that was set (exported) at the beginning when the shell woke up and typically
  # executed its .bash_aliases script.
  class Merge


    # Recursively merge (deep merge) two hash objects. The ruby Hash.merge()
    # instance method only performs first level merges which is not ideal if
    # you need to intelligently merge a deep tree.
    #
    # The merge rules state that if two keys have the same value and both
    # those values are themselves Hashes, they are again recursively merged.
    #
    # If merging values that are an array and a string, or a string and a
    # string, or a hash and an array, the winner is the value belonging to
    # the parameter hash.
    #
    # @param other_hash [Hash] the parameter hash to merge into ourselves
    def self.recursively_merge( object_1, object_2 )

      is_string_merge = object_1.instance_of?( String ) and object_2.instance_of?( String )
      is_struct_merge = object_1.instance_of?( Hash   ) and object_2.instance_of?( Hash   )

      unless is_string_merge or is_struct_merge
        puts "Cannot merge object of type [#{object_1.class()}] and [#{object_2.class()}]."
        return object_1
      end

      if is_string_merge
        puts "Request to merge two strings will simply return the first."
        return object_1
      end

      puts "Merging data structures with [#{object_1.length()}] and [#{object_2.length()}] keys."
      puts "Data structure 1 keys => #{object_1.keys().to_s}"
      puts "Data structure 2 keys => #{object_2.keys().to_s}"

      object_1.merge!( object_2 ) do | duplicate_key, value_1, value_2 |
        puts "Both data structures have the key [#{duplicate_key}] at the same level."
        recursively_merge( value_1, value_2 )
        value_1
      end


    end


  end


end
