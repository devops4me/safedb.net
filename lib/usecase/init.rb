#!/usr/bin/ruby
	
module SafeDb

  # The <b>init use case</b> should only be called the very first time a
  # <b>safe book</b> is created. The book can subsequently be instantiated
  # on different machines via the <b>remote storage</b> commands.
  #
  # == Init Use Case Observable Value
  #
  # - the book identifier is derived
  # - a password is collected
  # - salts and keys created in local index
  # - book index id stored in local index
  # - book crypt store directory created
  #
  #
  # ~/.safedb.net
  #     |
  #     |--- safedb-master-index-local.ini
  #     |--- safedb-activity-journal.log
  #     |
  #     |
  #     |--- safedb-master-crypt-files
  #              |
  #              |--- .git
  #              |--- safedb.master.book.ababab-ababab
  #                       |
  #                       |--- safedb.chapter.8d04ldabcd.txt
  #                       |--- safedb.chapter.fl3456asdf.txt
  #                       |--- safedb.chapter.pw9521pqwo.txt
  #
  #              |
  #              |--- safedb.master.book.cdcdcd-cdcdcd
  #                       |
  #                       |--- safedb.chapter.o3wertpoiu.txt
  #                       |--- safedb.chapter.xcvbrt2345.txt
  #     |
  #     |
  #     |--- safedb-session-crypt-files
  #              |
  #              |--- safedb-session-ababab-ababab-xxxxxx-xxxxxx-xxxxxx
  #                       |
  #                       |--- safedb.chapter.id1234abcd.txt
  #                       |--- safedb.chapter.id3456asdf.txt
  #                       |--- safedb.chapter.id9521pqwo.txt
  #              |
  #              |
  #              |--- safedb-session-ababab-ababab-xxxxxx-zzzzzz-zzzzzz
  #                       |
  #                       |--- safedb.chapter.id1234abcd.txt
  #                       |--- safedb.chapter.id3456asdf.txt
  #                       |--- safedb.chapter.id9521pqwo.txt
  #
  #     |--- safedb-session-index-files
  #              |
  #              |--- safedb-ababab-ababab-xxxxxx-xxxxxx-xxxxxx.ini
  #
  #
  #
  # == Local Index Path | ~/.safedb.net/safedb-local-index.ini
  # == master crypt store | ~/.safedb.net/safedb-master-crypts/crypts.xxxxxx-xxxxxx
  # == master crypt store | ~/.safedb.net/safedb-session-crypts/crypts.xxxxxx-xxxxxx
  #
  # == Alternat Error Flows
  #
  # An error will be thrown
  #
  # - if safe cannot create, extend, read or write the drive folder
  # - if the domain is already in the configuration file
  # - if domain has non alphanums, excl hyphens, underscores, @ symbols, periods
  # - if domain does not begin or end with alphanums.
  # - if non alpha-nums (excl at signs) appear consecutively
  # - if no alpha-nums appear in the string
  # - if the domain string's length is less than 5
  # - if "safedb.net" appears twice (or more) in a directory tree
  #
  class Init < UseCase

    attr_writer :password, :domain_name, :base_path


    # The init use case prepares the <b>safe</b> so that you can <b>open</b> an envelope,
    # <b>put</b> secrets into it and then <b>seal</b> (lock) it. Locking effectively writes
    # crypted blocks to both keystore and crypt store.
    def execute

      return unless ops_key_exists?

      KeyApi.init_app_domain( @domain_name, @base_path )
      keys_setup = KeyApi.is_domain_keys_setup?( @domain_name )

      if ( keys_setup )
        print_already_initialized
        return
      end

      domain_password = KeyPass.password_from_shell( true ) if @password.nil?
      domain_password = @password unless @password.nil?

      KeyApi.setup_domain_keys( @domain_name, domain_password, create_header() )
      print_domain_initialized

    end


    def pre_validation
    end


  end


end
