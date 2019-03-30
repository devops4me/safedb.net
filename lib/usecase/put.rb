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
  # At the point of calling the put use case
  #
  # - the safe must be <b>logged in</b> and a chapter and verse opened
  # - the key / value pair being put must pass minimum standards
  class Put < EditVerse

    attr_writer :credential_id, :credential_value

    # Execute the act of validating and then putting the credential key and
    # its value into the chapter and verse location, overwriting if need be.
    def edit_verse()

      @chapter_data.create_entry( @verse_id, @credential_id, @credential_value )

    end


  end


end
