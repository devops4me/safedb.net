#!/usr/bin/ruby

# Reopen the core ruby Hash class and add the below methods to it.
class Hash


  # Recursively merge (deep merge) this {Hash} data structure with another
  # given in the parameter.
  #
  # The core ruby {Hash.merge()} instance method only performs first level
  # merges which is not ideal in order to intelligently merge a deep tree.
  #
  # <tt>Merge Behaviour</tt>
  #
  # Currently this behaviour works only for Hash data structures that have
  # string keys (only) and either string or Hash values. It is interesting
  # only when duplicate keys are encountered at the same level. If the
  # duplicate key's value is
  # 
  # 1. a String - the incoming value is rejected and logged
  # 2. a Hash - the method is recalled to recursively merge
  # 
  # @param merge_me [Hash] the incoming hash data structure to merge
  def merge_recursively!( merge_me )

    self.merge!( merge_me ) do | key, value_1, value_2 |

      is_mergeable = value_1.kind_of?( Hash   ) && value_2.kind_of?( Hash   )
      are_both_str = value_1.kind_of?( String ) && value_2.kind_of?( String )
      not_the_same = are_both_str && ( value_1 != value_2 )

      reject_message( key, value_1, value_2 ) if not_the_same
      value_1.merge_recursively!( value_2 ) if is_mergeable
      value_1

    end

  end


  # Print a line to standard out stating that a same key (duplicate) map
  # entry has been encountered and here is the one we are rejecting.
  def reject_message( key, value_1, value_2 )
    puts "Refused to allow { #{key} => #{value_2} } to overwrite { #{key} => #{value_1} }"
  end


  # This method adds (logging its own contents) behaviour to
  # the standard library {Hash} class.
  #
  # @note This behaviour does not consider that SECRETS may be inside
  #    the key value maps - it logs itself without a care in the world.
  #    This functionality must be included if this behaviourr is used by
  #    any cryptography classes.
  #
  # The <tt>DEBUG</tt> log level is used for logging. To change this
  # create a new parameterized method.
  def log_contents

    log.debug(x) { "# --- ----------------------------------------------" }
    log.debug(x) { "# --- Map has [#{self.length}] key/value pairs." }
    log.debug(x) { "# --- ----------------------------------------------" }

    self.each do |the_key, the_value|

      padded_key = sprintf '%-33s', the_key
      log.debug(x) { "# --- #{padded_key} => #{the_value}" }

    end

    log.debug(x) { "# --- ----------------------------------------------" }

  end


end
