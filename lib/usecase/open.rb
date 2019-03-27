#!/usr/bin/ruby
	
module SafeDb

  # The <tt>open use case</tt> allows us to add (put), subtract (del)ete, change
  # (update) and list the secrets within an envelope (outer path) at a given
  # position (inner path), whether that envelope exists or not.
  #
  # Also see the <b>reopen</b> command which only differs from open in that it
  # fails if the path specified does not exist in either the sealed or session
  # envelopes.
  #
  # == The Open Path Parameter
  #
  # Open must be called with a single <b>path</b> parameter with an optional
  # single colon separating the outer (path to envelope) from the inner (path
  # within envelope).
  #
  # == Open (Path) Pre-Conditions
  #
  # The domain must have been initialized on this machine stating the path to
  # the base folder that contains the key and crypt material.
  #
  # To open a path these conditions must be true.
  #
  # - the shell session token must have been set at the session beginning
  # - a successful <tt>login</tt> command must have been issued
  # - the external drive (eg usb key) must be configured and accessible
  #
  # == Observable Value
  #
  # The observable value delivered by +[open]+ boils down to
  #
  # - an openkey (eg asdfx1234) and corresponding open encryption key
  # - open encryption key written to <tt>~/.safedb.net/open.keys/asdfx1234.x.txt</tt>
  # - the opened path (ending in filename) written to session.cache base in [safe]
  # - the INI string (were the file to be decrypted) would look like the below
  #
  #     [session]
  #     base.path = home/wifi
  #
  class Open < UseCase

    # The two paths that have been posted to the open command.
    # First is a relative path to the obfuscated envelope and then
    # the path in envelope to the point of interest.
    attr_writer :env_path, :key_path

    def execute

      return unless ops_key_exists?
      master_db = BookIndex.read()

      master_db[ ENV_PATH ] = @env_path
      master_db[ KEY_PATH ] = @key_path

      BookIndex.write( create_header(), master_db )

      # Show the mini dictionary at the opened chapter and verse location
      # More work is needed when for when only the chapter is opened in
      # which case we should show the list of verses and perhaps the count
      # of key value pairs each verse contains.
      Show.new.flow_of_events

    end


  end


end
