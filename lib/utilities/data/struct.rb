#!/usr/bin/ruby

module SafeDb

  # Data structure class provides behaviour for holding managing curating
  # and most important of all, merging, data.
  #
  # <tt>How to Merge Data Structures</tt>
  #
  # Recursively merge (deep merge) two {Hash} data structures. The core ruby
  # {Hash.merge()} instance method only performs first level merges which is
  # not ideal if you need to intelligently merge a deep tree.
  class Struct

    # Recursively merge (deep merge) two {Hash} data structures. The core ruby
    # {Hash.merge()} instance method only performs first level merges which is
    # not ideal if you need to intelligently merge a deep tree.
    #
    # <tt>Merge Behaviour</tt>
    #
    # Currently this behaviour works only for Hash data structures that have
    # string keys (only) and either string or Hash values. It is interesting
    # only when duplicate keys are encountered at the same level. If the
    # duplicate key's value is
    # 
    # 1. a String - the incoming value is rejected and logged
    # 2. a Hash - the method is recalled with these nested Hashes as parameters
    # 
    # @param struct_1 [Hash] the current receiving hash data structure
    # @param struct_2 [Hash] the incoming hash data structure to merge
    def self.recursively_merge!( struct_1, struct_2 )

      struct_1.merge!( struct_2 ) do | key, value_1, value_2 |

        is_mergeable = value_1.kind_of?( Hash   ) && value_2.kind_of?( Hash   )
        are_both_str = value_1.kind_of?( String ) && value_2.kind_of?( String )
        not_the_same = are_both_str && ( value_1 != value_2 )

        reject_message( key, value_1, value_2 ) if not_the_same
        recursively_merge!( value_1, value_2 ) if is_mergeable
        value_1

      end


    end


    private


    def self.reject_message( key, value_1, value_2 )
      the_message = "Refused to allow { #{key} => #{value_2} } to overwrite { #{key} => #{value_1} }"
      puts ""; puts the_message
    end

=begin
    require 'json'
    boys_school = JSON.parse( File.read( "merge-boys-school.json" ) )
    girls_school = JSON.parse( File.read( "merge-girls-school.json" ) )

    puts ""
    puts "#### #################################################"
    puts "#### ##### Joined Up Schools #########################"
    puts "#### #################################################"
    puts ""

    recursively_merge!( boys_school, girls_school )
    puts ""; puts JSON.pretty_generate( boys_school )
=end

  end


end
