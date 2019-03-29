#!/usr/bin/ruby
	
module SafeDb

  # The <b>put use case</b> follows <b>open</b> and it adds secrets into an
  # <em>(encrypted at rest)</em> <b>envelope</b>. Put can be called many times
  # and when done, the <b>lock use case</b> can be called to commit all opened
  # secrets into the configured storage engines.
  #
  # Calling <em>put</em> <b>before</b> calling open or <b>after</b> calling lock
  # is not allowed and will result in an error.
  #
  # == Put Pre-Conditions
  #
  # When the put use case is called - the below conditions ring true.
  #
  # - the <b>folder path</b> ending in ../../my must exist
  # - a session id, filename and encryption key ( in workstation config )
  #
  # == Observable Value
  #
  # The observable value delivered by +put+ boils down to
  #
  # - a new <b>friends.xyz123abc.os.txt</b> file if this is the first put.
  # - a new group_name/key_name (like monica/surname) entry is added if required
  # - a secret value is added against the key or updated if it already exists
  # - a new session id and encryption key is generated and used to re-encrypt
  class Put < EditVerse

    attr_writer :credential_id, :credential_value

    # Execute the act of validating and then putting the credential key and
    # its value into the chapter and verse location, overwriting if need be.
    def edit_verse()

      @chapter_data.create_entry( @verse_id, @credential_id, @credential_value )

    end


  end


end
