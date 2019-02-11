#!/usr/bin/ruby

#
# Reopen the core ruby Array class and add the below methods to it.
#
# Case Sensitivity rules for [ALL] the below methods that are
# added to the core Ruby string class.
#
# For case insensitive behaviour make sure you downcase both the
# string object and the parameter strings (or strings within
# other parameter objects, like arrays and hashes).
class Array


  # The returned string is a result of a union (join) of all the
  # (expected) string array elements followed by the <b>deletion</b>
  # of <b>all <em>non</em> alphanumeric characters</b>.
  #
  # <b>Disambiguating the String for Cross Platform Use</b>
  #
  # This behaviour is typically used for transforming text that is
  # about to be signed or digested (hashed). Removing all the non
  # alpha-numeric characters disambiguates the string.
  #
  # An example is the exclusion of line ending characters which in
  # Windows are different from Linux.
  #
  # This disambiguation means that signing functions will return the
  # same result on widely variant platfoms like Windows vs CoreOS.
  #
  # @return [String]
  #    Returns the alphanumeric union of the strings within this array.
  #
  # @raise [ArgumentError]
  #    if the array is nil or empty. Also an error will be thrown if
  #    the array contains objects that cannot be naturally converted
  #    to a string.
  def alphanumeric_union
    raise ArgumentError, "Cannot do alphanumeric union on an empty array." if self.empty?
    return self.join.to_alphanumeric
  end


  # Log the array using our logging mixin by printing every array
  # item into its own log line. In most cases we (the array) are
  # a list of strings, however if not, each item's to_string method
  # is invoked and the result printed using one log line.
  #
  # The INFO log level is used to log the lines - if this is not
  #   appropriate create a (level) parameterized log lines method.
  def log_lines

    self.each do |line|
      clean_line = line.to_s.chomp.gsub("\\n","")
      log.info(x) { line } if clean_line.length > 0
    end

  end


  # Get the text [in between] this and that delimeter [exclusively].
  # Exclusively means the returned text [does not] include either of
  # the matched delimeters (although an unmatched instance of [this]
  # delimeter may appear in the in-between text).
  #
  # --------------------
  # Multiple Delimiters
  # --------------------
  #
  # When multiple delimiters exist, the text returned is in between the
  #
  #  [a] - first occurrence of [this] delimeter AND the
  #  [b] - 1st occurrence of [that] delimeter [AFTER] the 1st delimiter
  #
  # Instances of [that] delimiter occurring before [this] are ignored.
  # The text could contain [this] delimeter instances but is guaranteed
  # not to contain a [that] delimeter.
  #
  # -----------
  # Parameters
  # -----------
  #
  #   this_delimiter : begin delimeter (not included in returned string)
  #   that_delimiter : end delimeter (not included in returned string)
  #
  # -----------
  # Exceptions
  # -----------
  #
  # An exception (error) will be thrown if
  #
  #   => any nil (or empties) exist in the input parameters
  #   => [this] delimeter does not appear in the in_string
  #   => [that] delimeter does not appear after [this] one
  #
  def before_and_after begin_delimeter, end_delimeter

    Throw.if_nil_or_empty_strings [ self, begin_delimeter, end_delimeter ]

    before_after_lines = []
    in_middle_bit = false

    self.each do |candidate_line|

      is_middle_boundary = !in_middle_bit && candidate_line.downcase.include?(begin_delimeter.downcase)
      if is_middle_boundary
        in_middle_bit = true
        next
      end

      unless in_middle_bit
        before_after_lines.push candidate_line
        next
      end

      #--
      #-- Now we are definitely in the middle bit.
      #-- Let's check for the middle end delimeter
      #--
      if candidate_line.downcase.include? end_delimeter.downcase
        in_middle_bit = false
      end

    end

    return before_after_lines

  end


  def middlle_bit begin_delimeter, end_delimeter

    Throw.if_nil_or_empty_strings [ self, begin_delimeter, end_delimeter ]

    middle_lines = []
    in_middle_bit = false

    self.each do |candidate_line|

      is_middle_boundary = !in_middle_bit && candidate_line.downcase.include?(begin_delimeter.downcase)
      if is_middle_boundary
        in_middle_bit = true
        next
      end

      end_of_middle = in_middle_bit && candidate_line.downcase.include?(end_delimeter.downcase)
      return middle_lines if end_of_middle
      
      #--
      #-- We are definitely in the middle bit.
      #--
      middle_lines.push(candidate_line) if in_middle_bit

    end

    unreachable_str = "This point should be unreachable unless facts are ended."
    raise RuntimeError.new unreachable_str

  end


end
