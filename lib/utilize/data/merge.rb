#!/usr/bin/ruby

module SafeDb

  # Recursively merge (deep merge) two {Hash} data structures. The core ruby
  # {Hash.merge()} instance method only performs first level merges which is
  # not ideal if you need to intelligently merge a deep tree.
  class Merge

    # Recursively merge (deep merge) two {Hash} data structures. The core ruby
    # {Hash.merge()} instance method only performs first level merges which is
    # not ideal if you need to intelligently merge a deep tree.
    #
    # This behaviour examines duplicate keys (and their values) provided by a
    # {Hash.merge!} block. If the two values are both {Hash} structures we use
    # recursion to deep merge them.
    #
    # If merging values that are an array and a string, or a string and a
    # string, or a hash and an array, the winner is the current (sitting) hash.
    # The incoming value is rejected and logged.
    #
    # @param struct_1 [Hash] the current receiving hash data structure
    # @param struct_2 [Hash] the incoming hash data structure to merge
    def self.recursively_merge!( struct_1, struct_2 )

      struct_1.merge!( struct_2 ) do | key, value_1, value_2 |

        is_mergeable = value_1.kind_of?( Hash   ) && value_2.kind_of?( Hash   )
        are_both_str = value_1.kind_of?( String ) && value_2.kind_of?( String )
        not_the_same = are_both_str && ( value_1 != value_2 )

        puts "Refusing to let { #{key} => #{value_2} } overwrite { #{key} => #{value_1} }" if not_the_same
        recursively_merge!( value_1, value_2 ) if is_mergeable
        value_1

      end


    end


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

  end


end
