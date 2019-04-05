#!/usr/bin/ruby
# coding: utf-8

module SafeDb

  # The parent SafeDb use case is designed to be extended by the cli
  # (command line) use cases like {SafeDb::Open}, {SafeDb::Put} and
  # {SafeDb::Lock} because it describes behaviour common to at least two
  # (but usually more) of the use cases.
  #
  # == Common Use Case Behaviour
  #
  # This {SafeDb::UseCase} use case is designed to be extended and does preparatory
  # work to create favourable and useful conditions to make use cases readable,
  # less repetitive, simpler and concise.
  #
  # == Machine (Workstation) Configuration File
  #
  # The global configuration filepath is found off the home directory using {Dir.home}.
  #
  #    ~/.safedb.net/safedb.net.configuration.ini
  #
  # The global configuration file in INI format is managed through the methods
  #
  # - {grab} read the value at key_name from the default section
  # - {stash} put directive key/value pair in default section
  # - {read} read the value at key_name from the parameter section
  # - {write} put directive key/value pair in parameter section
  class UseCase

    # This use case is initialized primary by resolving the configured
    # +general and use case specific facts+. To access the general facts,
    # a domain name is expected in the parameter delegated by the extension
    # use case classes.
    def initialize

      class_name = self.class.name.split(":").last.downcase
      is_no_token_usecase = [ "token", "init", "id" ].include? class_name
      return if is_no_token_usecase

      exit(100) unless ops_key_exists?

      fact_filepath = File.sister_filepath( self, "ini", :execute )
      log.info(x) { "Search location for INI factfile is [#{fact_filepath}]" }
      return unless File.exists?( fact_filepath )

      @facts = FactFind.new()
      add_secret_facts @facts
      @facts.assimilate_ini_file( fact_filepath )
      @dictionary = @facts.f[ @facts.to_symbol( class_name ) ]

    end


    # This parental behaviour decrypts and reads the ubiquitous chapter and verse
    # data structures and indices.
    def read_verse()

# @todo usecase => consider doing the book index opening with initializer UNLESS token/admin use case

      @book_index = BookIndex.new()
      return if @book_index.unopened_chapter_verse()
      @verse = @book_index.get_open_verse_data()

    end


    # This parental behaviour encrypts and writes out the in-play chapter
    # and verse data. This behaviour also deletes the crypt file belonging
    # to the now superceeded chapter state.
    def update_verse()

      @book_index.write_open_chapter()
      Show.new.flow_of_events

    end


    # Execute the use cases's flow from beginning when
    # you validate the input and parameters through the
    # memorize and execute.
    def flow_of_events

      check_pre_conditions
      execute
      check_post_conditions

    end


    # Validate the input parameters and check that the current
    # state is perfect for executing the use case.
    #
    # If either of the above fail - the validation function should
    # set a human readable string and then throw an exception.
    def check_pre_conditions

      begin

        pre_validation

      rescue OpenError::CliError => e

        puts ""
        puts "Your command did not complete successfully."
        puts "Pre validation checks failed."
        puts ""
        puts "   => #{e.message}"
        puts ""
        abort e.message
      end

    end


    # Override me if you need to
    def pre_validation

    end


    # After the main flow of events certain state conditions
    # must hold true thus demonstrating that the observable
    # value has indeed ben delivered.
    #
    # Child classes should subclass this method and place any
    # post execution (post condition) checks in it and then
    # make a call to this method through the "super" keyword.
    def check_post_conditions

      begin

        post_validation

      rescue OpenError::CliError => e

        puts ""
        puts "Your command did not complete successfully."
        puts "Post validation checks failed."
        puts ""
        puts "   => #{e.message}"
        ####        puts "   => #{e.culprit}"
        puts ""
        abort e.message
      end

    end


    # Child classes should subclass this method and place any
    # post execution (post condition) checks in it and then
    # make a call to this method through the "super" keyword if
    # this method gets any global behaviour in it worth calling.
    def post_validation

    end


    # Execute the main flow of events of the use case. Any
    # exceptions thrown are captured and if the instance
    # variale [@human_readable_message] is set - tell the
    # user about it. Without any message - just tell the
    # user something went wrong and tell them where the logs
    # are that might carry more information.
    def execute

    end


    private


    ENV_VAR_PREFIX_A = "evar."
    ENV_VAR_PREFIX_B = "@evar."
    FILE_KEY_PREFIX = "file::"
    FILE_CONTENT_KEY = "content64"
    FILE_NAME_KEY = "filename"
    COMMANDMENT = "safe"
    ENV_VAR_KEY_NAME = "SAFE_TTY_TOKEN"

    SAFE_FLAGSHIP_NAME = "safedb.net"
    MASTER_INDEX_LOCAL_FILE = File.join( Dir.home, ".#{SAFE_FLAGSHIP_NAME}/safedb-master-index-local.ini" )
    ENV_PATH = "env.path"
    KEY_PATH = "key.path"
    ENVELOPE_KEY_PREFIX = "envelope@"


    def add_secret_facts fact_db

      master_db = BookIndex.read()
      raise ArgumentError.new "There is no open chapter here." if unopened_envelope?( master_db )
      chapter_id = ENVELOPE_KEY_PREFIX + master_db[ ENV_PATH ]
      verse_id = master_db[ KEY_PATH ]
      chapter_data = DataStore.from_json( Lock.content_unlock( master_db[ chapter_id ] ) )
      mini_dictionary = chapter_data[ master_db[ KEY_PATH ] ]

      mini_dictionary.each do | key_str, value_str|
        fact_db.assimilate_fact( "secrets", key_str, value_str )
      end

    end


    def ops_key_exists?

      log_env()

      if ( ENV.has_key? ENV_VAR_KEY_NAME )
        return true
      end

      puts ""
      puts "safe needs you to create a session key."
      puts "To automate this step see the documentation."
      puts "To create the key run the below command."
      puts ""
      puts "    export #{ENV_VAR_KEY_NAME}=`#{COMMANDMENT} token`"
      puts ""
      puts "Those are backticks surrounding `#{COMMANDMENT} token`"
      puts "Not apostrophes."
      puts ""

      return false

    end


    def log_env()

      log.info(x) { "Gem Root Folder    => #{Gem.dir()}" }
      log.info(x) { "Gem Config File    => #{Gem.config_file()}" }
      log.info(x) { "Gem Binary Path    => #{Gem.default_bindir()}" }
      log.info(x) { "Gem Host Path      => #{Gem.host()}" }
      log.info(x) { "Gem Caller Folder  => #{Gem.location_of_caller()}" }
      log.info(x) { "Gem Paths List     => #{Gem.path()}" }
      log.info(x) { "Gem Platforms      => #{Gem.platforms()}" }
      log.info(x) { "Gem Ruby Version X => #{Gem.ruby()}" }
      log.info(x) { "Gem Ruby Version Y => #{Gem::VERSION}" }
      log.info(x) { "Gem Ruby Version Z => #{Gem.latest_rubygems_version()}" }
      log.info(x) { "Gem User Folder    => #{Gem.user_dir()}" }
      log.info(x) { "Gem User Home      => #{Gem.user_home()}" }

      return

    end


=begin

    def unopened_envelope?( key_database )

      return false if key_database.has_key?( ENV_PATH )
      print_unopened_envelope()
      return true

    end


    def print_unopened_envelope()

      puts ""
      puts "Problem - before creating, reading or changing data you"
      puts "must first open a path to it like this."
      puts ""
      puts "    #{COMMANDMENT} open email.accounts joe@gmail.com"
      puts ""
      puts " then you put data at that path"
      puts ""
      puts "    #{COMMANDMENT} put username joebloggs"
      puts "    #{COMMANDMENT} put password jo3s-s3cr3t"
      puts "    #{COMMANDMENT} put phone-no 07123456789"
      puts "    #{COMMANDMENT} put question \"Mums maiden name\""
      puts ""
      puts " and why not read it back"
      puts ""
      puts "    #{COMMANDMENT} get password"
      puts ""
      puts " then close the path."
      puts ""
      puts "    #{COMMANDMENT} close"
      puts ""

    end

=end


  end


end
