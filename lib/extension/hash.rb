#!/usr/bin/ruby

# Reopen the core ruby Hash class and add the below methods to it.
class Hash

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
