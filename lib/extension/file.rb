#!/usr/bin/ruby

# Reopen the core ruby File class and add the below methods to it.
class File

    # Get the full filepath of a sister file that potentially lives
    # in the same directory that the leaf class is executing from and
    # has the same name as the leaf class but a different extension.
    #
    # == Usage
    #
    # If class OpenFoo:Bar extends class OpenFoo:Baz and we are looking
    # for an INI file in the folder that OpenFoo:Bar lives in we can
    # call this method within OpenFoo:Baz like this.
    #
    #   ini_filepath = sister_filepath( "ini", :execute )
    #   # => /var/lib/gems/2.5.0/gems/fooey-0.2.99/lib/barry/bazzy/bar.ini
    #
    # == Common Implementation
    #
    # Object orientation scuppers the commonly used technique which
    # derives the path from __FILE__
    #
    #    class_directory = File.dirname( __FILE__ )
    #    leaf_class_name = self.class.name.split(":").last.downcase
    #    sister_filepath = File.join ( class_directory, "#{leaf_class_name}.#{extension}" )
    #
    # With object orientation - running the above code within the
    # abstracted (parent) class would produce a resultant filepath
    # based on the folder the parent class is in rather than the
    # extended "concrete" class.
    #
    # == Value Proposition
    #
    # You can call this method from the parent (abstract) class and it
    # will still correctly return the path to the potential sister file
    # living in the directory that the leaf class sits in.
    #
    # Put differently - this extension method allows code executing in
    # the parent class to correctly pinpoint a file in the directory of
    # the leaf class be it in the same or a different folder.
    #
    # @param caller
    #     the calling class object usually passed in using <tt>self</tt>
    #
    # @param extension
    #     the extension of a sister file that carries the same simple
    #     (downcased) name of the leaf class of this method's caller.
    #
    #     Omit the (segregating) period character when providing this
    #     extension parameter.
    #
    # @param method_symbol
    #     the method name in symbolic form of any method defined in
    #     the leaf class even if the method overrides one of the same
    #     name in the parent class.
    #
    # @return the filepath of a potential sister file living in the same
    #         directory as the class, bearing the same (downcased) name
    #         as the class with the specified extension.
    def self.sister_filepath caller, extension, method_symbol

      leaf_classname = caller.class.name.split(":").last.downcase
      execute_method = caller.method( method_symbol )
      leaf_classpath = execute_method.source_location.first
      leaf_directory = File.dirname( leaf_classpath )
      lower_filename = "#{leaf_classname}.#{extension}"
      return File.join( leaf_directory, lower_filename )

    end


  # This method adds (logging its own contents) behaviour to
  # the standard library {File} class. If this File points to
  # a directory - that folder's single level content files are
  # listed inside the logs.
  #
  # The <tt>DEBUG</tt> log level is used for logging. To change this
  # create a new parameterized method.
  #
  # @param file_context [String] context denotes the whys and wherefores of this file.
  def log_contents file_context

    ## This will fail - add physical raise statement.
    Throw.if_not_exists self

    log.debug(x) { "# -- ------------------------------------------------------------------------ #" }
    log.debug(x) { "# -- ------------------------------------------------------------------------ #" }
    log.debug(x) { "# -- The File Path to Log => #{self}" }

    hr_file_size = PrettyPrint.byte_size( File.size(self) )
    dotless_extension = File.extname( self )[1..-1]
    parent_dir_name = File.basename( File.dirname( self ) )
    file_name = File.basename self
    is_zip = dotless_extension.eql? "zip"

    log.debug(x) { "# -- ------------------------------------------------------------------------ #" }
    log.debug(x) { "# -- File Name => #{file_name}" }
    log.debug(x) { "# -- File Size => #{hr_file_size}" }
    log.debug(x) { "# -- File Type => #{file_context}" }
    log.debug(x) { "# -- In Folder => #{parent_dir_name}" }
    log.debug(x) { "# -- ------------------------------------------------------------------------ #" }

    log.debug(x) { "File #{file_name} is a zip (binary) file." } if is_zip
    return if is_zip

    File.open( self, "r") do | file_obj |
      line_no = 1
      file_obj.each_line do | file_line |
        line_num = sprintf '%03d', line_no
        clean_line = file_line.chomp.strip
        log.debug(x) { "# -- [#{line_num}] - #{clean_line}" }
        line_no += 1
      end
    end

    log.debug(x) { "# -- ------------------------------------------------------------------------ #" }
    log.debug(x) { "# -- [#{file_context}] End of File [ #{File.basename(self)} ]" }
    log.debug(x) { "# -- ------------------------------------------------------------------------ #" }

  end

end
