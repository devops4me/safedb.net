#!/usr/bin/ruby
# coding: utf-8

module OpenSession


  # Require every file with a dot rb extension that is
  # +either directly in or recursively below+ the calling gem's
  # directory.
  #
  # Note that this class and its methods depend on an initialized
  # logger so as a pre-condition, ensure the logging has been
  # instantiated before calling.
  #
  # == The Base Require Path
  #
  # Here is an example of the base require path being derived.
  #
  # @example
  #   Let's assume that the
  #
  #   - ruby gems version is <tt>2.3.0</tt>, and the
  #   - safe version is <tt>0.0.944</tt>, and the
  #   - calling class is in the <tt>lib</tt> directory
  #
  #   +then+ the gem base path would be
  #
  #   <tt>/var/lib/gems/2.3.0/gems/safe-0.0.944/lib</tt>
  #
  #   This means every ruby (.rb) file both +directly in+ and
  #   +recursively below+ the <tt>lib</tt> directory will be
  #   required.
  #
  #
  # == Requiring Parental Classes Before Child Classes
  #
  # This is a common problem when bringing classes in to join
  # the fray. We must require the +Planet+ class before
  # we require the +Neptune+ class.
  #
  #  <tt>class Neptune < Planet</tt>
  #
  # The solution lies in the directory structure between parent
  # and child classes and this is illustrated by +plugins+.
  #
  # ------------------------
  # Plugins Folder Structure
  # ------------------------
  #
  # In the plugins hierarchy, you'll notice that the child classes
  # are always below the parents. This strategy works if the +inheritors+
  # are in the same gem as the +inherited+.
  class RecursivelyRequire

    # Require every file with a dot rb extension that is
    # +either in or recursively below+ the file path given
    # in the parameter.
    #
    # This method logs every file that is required using
    # the INFO log level.
    #
    # == Requiring Parental Classes Before Child Classes
    #
    # This is a common problem when bringing classes in to join
    # the fray. We must require the +Planet+ class before
    # we require the +Neptune+ class.
    #
    #  <tt>class Neptune < Planet</tt>
    #
    # The solution lies in the directory structure between parent
    # and child classes and this is illustrated by +plugins+.
    #
    # ------------------------
    # Plugins Folder Structure
    # ------------------------
    #
    # In the plugins hierarchy, you'll notice that the child classes
    # are always below the parents. This strategy works if the +inheritors+
    # are in the same gem as the +inherited+.
    #
    # This require loop is <tt>breadth first</tt> not <tt>depth first</tt>
    # so all the parent (base) classes in plugins will be required before
    # their extension classes in the lower subdirectories.
    #
    # @param gem_filepath [String] path to callling gem (use <tt>__FILE</tt>)
    def self.now gem_filepath


############      require_relative "../cryptools/keygen"
      require_relative "../usecase/cmd"


      gem_basepath = File.expand_path "..", gem_filepath

      log.info(x) { "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" }
      log.info(x) { "@@@@ Require Gems In or Under [#{gem_basepath}]" }
      log.info(x) { "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" }

      Dir["#{gem_basepath}/**/*.rb"].each do |gem_path|

        log.info(x) { "@@@@ => #{gem_path}" }
        require gem_path

      end

      log.info(x) { "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" }

    end

  end

end
