#!/usr/bin/ruby

module SafeDb

  # --
  # -- -----------------
  # -- Fact Production
  # -- -----------------
  # --
  # -- The fact tree is tasked with fact production
  # -- (population). Fact production is done by [consuming]
  # --
  # --   [1] - simple string, number of boolean facts
  # --   [2] - facts already produced
  # --   [3] - identity facts from command line and environment
  # --   [4] - software (behaviour) that derives facts
  # --   [5] - inherited (extended) facts from (OO) parents
  # --
  # --
  # --
  # -- -----------------------------------------
  # -- The 4 Universal (DevOps) Creation Facts
  # -- -----------------------------------------
  # --
  # -- No matter the (DevOps) eco-system being fabricated, these four
  # -- facts prevail and stand out.
  # --
  # -- Every time a DevOps [eco-system] is created, cloned, or recovered,
  # -- a small cluster of core facts endure to define the instance and act
  # -- as the identification basis of all new eco-system resources.
  # --
  # -- The 4 facts underpinning eco-system creation are
  # --
  # --   [1] - [what] is being built
  # --   [2] - [when] did the building begin
  # --   [3] - [who] instigated it (and from)
  # --   [4] - [which] workstation.
  # --
  # -- ---------------------------------------
  # -- DevOps 4 Creational [Instance] Facts
  # -- ---------------------------------------
  # --
  # -- The core instance identities used and reused time and again relate to
  # --
  # --   [1] - plugin      (eg) wordpress.hub or jenkins.hub
  # --   [2] - time        (eg) 18036.0952.065
  # --   [3] - user        (eg) peterpan
  # --   [4] - workstation (eg) laptop_susie or hp_desktop
  # --
  # --
  class FactFind

    @@eval_prefix = "rb>>"

    # The fact tree values can be referenced using the @f
    # specifier with a 2 dimensional key.
    attr_reader :f


    # This method constructs the FactFind object and tree database
    # and initializers the root fact container structures.
    def initialize

      @f = {}
      @s = {}

# --->      @f.store symbol(plugin_id), {}
# --->      @p = @f[symbol(plugin_id)]

    end


    # Assimilate the gem's main factbase fact file into
    # the structure that is exposed to outside classes
    # as the instance variable @f (a 2D array type).
    #
    # The factfile to assimilate is always expected to
    # exist in folder [ ../factbase ]
    #
    # The factfile name within the above folder is expected
    # to be presented in the parameter.
    #
    # @param factfile_name [String] name of factfile to assimilate
    def assimilate factfile_name

      factfile_dir = File.join(File.dirname(File.expand_path(__FILE__)), "../factbase")
      factfile_path = File.join factfile_dir, factfile_name

      log.info(x) { "Assimilating factfile in folder => #{factfile_dir}" }
      log.info(x) { "Assimilating factfile with name => #{factfile_name}" }

      assimilate_ini_file factfile_path

    end


    # ----> -------------------------------------------------->
    # ----> How to Write a Custom Error
    # ----> -------------------------------------------------->
    # ----> Add a custom data attributes to your exception
    # ----> You can add custom data to your exception just like you'd do it in any other class. Let's add an attribute reader to our class and update the constructor.
    # ----> class MyError < StandardError
    # ---->   attr_reader :thing
    # ---->   def initialize(msg="My default message", thing="apple")
    # ---->     @thing = thing
    # ---->     super(msg)
    # ---->   end
    # ----> end
    # ----> -------------------------------------------------->
    # ----> Using the Custom Error Class
    # ----> -------------------------------------------------->
    # ----> begin
    # ---->   raise MyError.new("my message", "my thing")
    # ----> rescue => e
    # ---->   puts e.thing # "my thing"
    # ----> end
    # ----> -------------------------------------------------->


    # -- ------------------------------------------- -- #
    # --                                             -- #
    # --  Template                                   -- #
    # --                                             -- #
    # --   The longest river in africa is without    -- #
    # --   doubt the @[africa|longest.river]. Now    -- #
    # --   @[south.america|most.spoken] is the       -- #
    # --   most common language in south america.    -- #
    # --                                             -- #
    # --   The population of the americas            -- #
    # --   is @[americas|population] according to
    # --   the Harvard 2015 census.
    # --                                             -- #
    # -- ------------------------------------------- -- #
    # --                                             -- #
    # --  Ruby Code                                  -- #
    # --                                             -- #
    # --   double_north_america_pop = @f[:north_america][:population] * 2
    # --                                             -- #
    # -- ------------------------------------------- -- #
    # -- Parameters                                  -- #
    # --   factory_facts : instantiated 2D hash      -- #
    # --   ini_filepath : path to factfile to read   -- #
    # --                                             -- #
    # -- Dependencies and Assumptions                -- #
    # --   the [inifile] gem is installed            -- #
    # --   file exists at the ini_filepath           -- #
    # --   factory_facts are instantiated            -- #
    # --   identity facts like @i[:plugin] exist     -- #
    # -- ------------------------------------------- -- #
    def assimilate_ini_file ini_filepath

      fact_filename = File.basename ini_filepath
      log_begin fact_filename

      no_file = "No (ini) factfile found here => #{ini_filepath}"
      raise ArgumentError.new no_file unless File.exists? ini_filepath

      # --
      # -- Use the inifile gem to parse and read the fact
      # -- file contents into Ruby's map structures.
      # --
      begin

        map_facts = IniFile.load ini_filepath
        map_facts.each do | group_str, key_str, input_value |
          assimilate_fact group_str, key_str, input_value
        end

      rescue Exception => e

        log.fatal(x) { "## ############################ #################################" }
        log.fatal(x) { "## Fact File Assimilation Error ---------------------------------" }
        log.fatal(x) { "## ############################ #################################" }
        log.fatal(x) { "## File  => #{ini_filepath}"                                       }
        log.fatal(x) { "## Error => #{e.message}"                                          }
        log.fatal(x) { "## ############################ #################################" }
        e.backtrace.log_lines
        log.fatal(x) { "## ############################ #################################" }

        raise e

      end

      log_end fact_filename

    end



    # This method assimilates a two-dimensional fact bringing it into the
    # fact tree fold.
    #
    # Once assimilated, this fact with a 2D index can be reused
    # - for future fact resolution
    # - by classes with access to the fact tree
    # - for dynamic template resolution
    #
    # @param fact_group_str the first dimensional fact key
    # @param fact_key_str the second dimensional fact key
    # @param fact_value_str value of the fact to assimilate
    def assimilate_fact fact_group_str, fact_key_str, fact_value_str

      grp_symbol = fact_group_str.gsub(".", "_").to_sym
      key_symbol = fact_key_str.gsub(".", "_").to_sym

      raise ArgumentError, "Assimilating Fact [ #{fact_group_str} ][ #{fact_key_str} ] => Value is NIL" if fact_value_str.nil?
      fact_string = fact_value_str.strip

      begin

        raise ArgumentError, "Fact object in section #{fact_group_str} with key #{fact_key_str} is nil." if fact_string.nil?
        eval_value = evaluate( fact_string )
        add_fact grp_symbol, to_symbol(fact_key_str), eval_value

      rescue Exception => e

        log.fatal(x) { "## ##################### #################################" }
        log.fatal(x) { "## Fact Evaluation Error ---------------------------------" }
        log.fatal(x) { "## ##################### #################################" }
        log.fatal(x) { "## Fact Family => #{fact_group_str}"                        }
        log.fatal(x) { "## Fact Key    => #{fact_key_str}"                          }
        log.fatal(x) { "## Fact Stmt   => #{fact_string}"                           }
        log.fatal(x) { "## Fact Error  => #{e.message}"                             }
        log.fatal(x) { "## ##################### #################################" }
        e.backtrace.log_lines

        raise e

      end

      unless @f.has_key? grp_symbol then

        log.debug(x){ "# @@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ #" }
        log.debug(x){ "# @@ the [#{fact_group_str}] silo facts."                          }
        log.debug(x){ "# @@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ #" }

      end

      id_keystring = "#{grp_symbol}#{key_symbol}".downcase
      sensitive = id_keystring.includes_any? [ "secret", "password", "credential", "creds" ]
      print_value = "****************"
      print_value = eval_value unless sensitive

      fw_key = sprintf '%-33s', "@f[:#{grp_symbol}][:#{key_symbol}]"
      log.debug(x){ "#{fw_key} => #{print_value}" }

    end



    # This static method converts from string to symbol.
    # @param from_string the neither nil nor empty string to convert to a symbol
    # @return a symbol representation of the input string
    def to_symbol from_string
      return from_string.strip.gsub(".", "_").to_sym
    end



    private



    def add_fact group_symbol, key_symbol, key_value

      fact_component = "[group]=> #{group_symbol} [key]=> #{key_symbol} [value]=> #{key_value}"
      nil_error_text = "Neither fact coordinates nor values can be nil. #{fact_component}"
      raise ArgumentError.new nil_error_text if group_symbol.nil? || key_symbol.nil? || key_value.nil?

      if @f.has_key? group_symbol then

        # -- This isn't the first fact within this group
        # -- so store the new fact key/value pair within
        # -- the group's namespace.
        @f[group_symbol][key_symbol] = key_value

      else

        # -- Create a new umbrella grouping against which
        # -- the new key-value pairing will be inserted.
        @f.store group_symbol, { key_symbol => key_value }

      end

      # -- The @s sibling hash is updated to reflect the
      # -- key-value pairs within the current group. This
      # -- allows @s to be used as shorthand within INI
      # -- file fact definition statements.
      @s = @f[group_symbol]

    end


    def evaluate string

      # -----> @todo raise a FactError here

      raise RuntimeError.new "Fact to Evaluate is Nil." if string.nil?
      return string unless string.start_with? @@eval_prefix
      return eval( string.gsub @@eval_prefix, "" )

    end


    def log_begin the_filename

      log.info(x) { "-                                                         -" }
      log.info(x) { "# @@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@ #" }
      log.info(x) { "# -- ------------------------------------------------- -- #" }
      log.info(x) { "# -- [= BEGIN THE ASSIMILATION =] #{the_filename}"          }
      log.info(x) { "# -- ------------------------------------------------- -- #" }
      log.info(x) { "# @@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@ #" }

    end


    def log_end the_filename

      log.info(x) { "# @@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@ #" }
      log.info(x) { "# -- ------------------------------------------------- -- #" }
      log.info(x) { "# -- [= END ASSIMILATION =] #{the_filename}"                }
      log.info(x) { "# -- ------------------------------------------------- -- #" }
      log.info(x) { "# @@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@ #" }
      log.info(x) { "-                                                         -" }
      log.info(x) { "-                                                         -" }
      log.info(x) { "-                                                         -" }

    end


  end


end
