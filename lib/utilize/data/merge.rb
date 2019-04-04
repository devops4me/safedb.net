#!/usr/bin/ruby

module SafeDb

  # The shell session can access the 152 characters of crypt and salt text
  # that was set (exported) at the beginning when the shell woke up and typically
  # executed its .bash_aliases script.
  class ShellSession


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
  def recursive_merge( other_hash )

    r = {}
    merge( other_hash ) do | key, oldval, newval |

      puts ""
      puts "### #######################################################"
      puts "### #######################################################"
      puts "### #######################################################"
      puts "### Asked to recursively merge the below."
      puts "### #######################################################"
      puts ""
      puts self.to_json()
      puts ""
      puts "### #######################################################"
      puts "### #######################################################"
      puts ""
      puts other_hash.to_json()
      puts ""

      r[key] = oldval.class == self.class ? oldval.recursive_merge( newval ) : newval

    end

  end

  def self.deep_merge!(tgt_hash, src_hash)
    tgt_hash.merge!(src_hash) { |key, oldval, newval|
      if oldval.kind_of?(Hash) && newval.kind_of?(Hash)
        deep_merge!(oldval, newval)
      else
        newval
      end
    }
  end



  end


end
