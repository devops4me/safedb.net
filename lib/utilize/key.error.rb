#!/usr/bin/ruby

module SafeDb


  # This class is the parent to all opensession errors
  # that originate from the command line.
  #
  # All opensession cli originating errors are about
  #
  # - a problem with the input or
  # - a problem with the current state or
  # - a predictable future problem
  class KeyError < StandardError


    # Initialize the error and provide a culprit
    # object which will be to-stringed and given
    # out as evidence (look at this)!
    #
    # This method will take care of loggin the error.
    #
    # @param message [String] human readable error message
    # @param culprit [Object] object that is either pertinent, a culprit or culpable 
    def initialize message, culprit

      super(message)

      @the_culprit = culprit

      log.info(x) { "An [Error] Occured => #{message}" }
      log.info(x) { "Object of Interest => #{culprit.to_s}" } unless culprit.nil?
      log.info(x) { "Class Name Culprit => #{culprit.class.name}" }
      log.info(x) { "Error Message From => #{self.class.name}" }

      thread_backtrace = Thread.current.backtrace.join("\n")
      thread_backtrace.to_s.log_lines

    end


    # This method gives interested parties the object that
    # is at the centre of the exception. This object is either
    # very pertinent, culpable or at the very least, interesting.
    #
    # @return [String] string representation of culpable object
    def culprit
      return "No culprit identified." if @the_culprit.nil?
      return @the_culprit.to_s
    end


    # Assert that the parameter string attribute is <b>not new</b> which
    # means neither nil, nor empty nor consists solely of whitespace.
    #
    # The <b>NEW</b> acronym tells us that a bearer worthy of the name is
    #
    # - neither <b>N</b>il
    # - nor <b>E</b>mpty
    # - nor consists solely of <b>W</b>hitespace
    #
    # @param the_attribute [String]
    #    raise a {KeyError} if the attribute is not new.
    #
    # @param the_desc [String]
    #    a description of th attribute
    #
    # @raise [KeyError]
    #
    # The attribute cannot be <b>NEW</b>. The <b>NEW acronym</b> asserts
    # that the attribute is
    #
    # - neither <b>N</b>il
    # - nor <b>E</b>mpty
    # - nor <b>W</b>hitespace only
    #
    def self.not_new the_attribute, the_desc

      attribute_new = the_attribute.nil? || the_attribute.chomp.strip.empty?
      return unless attribute_new

      msg = "[the_desc] is either nil, empty or consists solely of whitespace."
      raise KeyError.new( msg, the_desc )

    end


  end

=begin
  # Throw this error if the configured safe directory points to a file.
  class SafeDirectoryIsFile < OpenError::CliError; end;

  # Throw this error if safe directory path is either nil or empty.
  class SafeDirNotConfigured < OpenError::CliError; end;

  # Throw this error if the email address is nil, empty or less than 5 characters.
  class EmailAddrNotConfigured < OpenError::CliError; end;

  # Throw this error if the store url is either nil or empty.
  class StoreUrlNotConfigured < OpenError::CliError; end;

  # Throw if "prime folder" name occurs 2 or more times in the path.
  class SafePrimeNameRepeated < OpenError::CliError; end;

  # Throw if "prime folder" name occurs 2 or more times in the path.
  class SafePrimeNameNotAtEnd < OpenError::CliError; end;
=end

end
