#!/usr/bin/ruby

module SafeDb


  # The responsibility of this class is to generate truly secure random
  # strings that can be used to provide passwords and identifiers.
  class KeyRandom


    # --
    # -- Engineer a raw password that is similar (approximate) in
    # -- length to the integer parameter.
    # --
    def self.strong_key approx_length

      non_alphanum = SecureRandom.urlsafe_base64(approx_length);
      return non_alphanum.delete("-_")

    end


  end


end
