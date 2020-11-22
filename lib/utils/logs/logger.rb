require "logger"

# [MIXIN] magic is deployed to hand out DevOps quality logging
# features to any class that includes the logging module.
#
# When logging facilities are not ready we need to log just to
# stdout but when they are we need to use them.
#
# mixin power enables one class to give the logfile path and all
# classes will suddenly retrieve a another logger and use that.
#
#   include Logging
#   def doImportant
#     log.warn(x) "unhappy about doing this"
#     do_anyway
#     log.debug(x) "all good it was okay"
#   end
#
# So what are Mixins?
#
# Refer to the below link for excellent coverage of mixins.
# @see http://ruby-doc.com/docs/ProgrammingRuby/html/tut_modules.html
#
module LogImpl

  @@gem_base = File.join( File.join( Dir.home, ".config" ), "safe" )
  FileUtils.mkdir_p( @@gem_base ) unless File.exists?( @@gem_base )
  @@log_path = File.join( @@gem_base, "safe-activity.log" )


  # Classes that include (MIXIN) this logging module will
  # have access to this logger method.
  #
  # [memoization] is implemented here for performance and
  # will only initiate a logger under 2 circumstances
  #
  #   [1] - the first call (returns a STDOUT logger)
  #   [2] - the call after the logfile path is set
  #          (returns a more sophisticated logger)
  def log

    @@log_class ||= get_logger

  end


  # This Ruby behavioural snippet allows the logger to print 3 crucial
  # pieces of information for the troubleshooter (detective) so that they
  # may ascertain
  #
  # - the [module] the logging call came from
  # - the [method] the logging call came from
  # - line number origins of the logging call
  #
  # To use this method you can make calls like this
  #
  # - log.info(x) { "Log many things about where I am now." }
  # - log.warn(x) { "Log many things about where I am now." }
  #
  def x

    module_name = File.basename caller_locations(1,1).first.absolute_path, ".rb"
    method_name = caller_locations(1,1).first.base_label
    line_number = caller_locations(1,1).first.lineno

    "#{module_name} | #{method_name} | (line #{line_number}) "

  end


  # This method returns an initialized logger.
  #
  # The logger returned may write to
  #
  # - a simple file
  # - a service like fluentd
  # - a message queue
  # - a nosql database
  # - all of the above
  #
  # Not that [memoization] should be used so that this method
  # gets called ideally just once although in practise it may
  # turn out to be a handful of times.
  #
  # @return [Logger] return an initialized logger object
  def get_logger

    file_logger = Logger.new @@log_path
    file_logger.level = Logger::INFO
    original_formatter = Logger::Formatter.new

    file_logger.formatter = proc { |severity, datetime, progname, msg|
      original_formatter.call( severity, datetime, progname, msg.dump.chomp.strip )
    }

    return file_logger

  end


  # Overtly long file paths in the log files sometimes hamper readability
  # and this method improves the situation by returning just the two
  # immediate ancestors of the file (or folder) path.
  #
  # @example A really long input like
  #          <tt>/home/joe/project/degrees/math/2020</tt>
  #          is reduced to
  #          <tt>degrees/math/2020</tt>
  #
  # So this method returns the name of the grandparent folder then parent folder
  # and then the most significant file (or folder) name.
  #
  # When this is not possible due to the filepath being colisively near the
  # filesystem's root, it returns the parameter name.
  # 
  # @param object_path [String] overtly long path that will be made more readable
  # @return [String] the (separated) three most significant path name segments
  def nickname object_path

    object_name   = File.basename object_path
    parent_folder = File.dirname  object_path
    parent_name   = File.basename parent_folder
    granny_folder = File.dirname  parent_folder
    granny_name   = File.basename granny_folder

    return [granny_name,parent_name,object_name].join("/")

  end


end
