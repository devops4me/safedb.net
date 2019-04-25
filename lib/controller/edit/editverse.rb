#!/usr/bin/ruby
	
module SafeDb

  # Any {Controller} class wishing to edit a safe verse can make use of the functionality
  # in this parent by exposing an edit_verse() method.
  #
  # Classes extending this class will have access to
  #
  # - a <tt>@chapther_data</tt> **data** structure
  # - a <tt>@chapther_id</tt> **string** index
  # - a <tt>@has_chapter</tt> **boolean** indicator
  # - a <tt>@verse_data</tt> **data** structure
  # - a <tt>@verse_id</tt> **string** index
  # - a <tt>@has_verse</tt> **boolean** indicator
  #
  # After the edit method completes the amended chapter data structure will be encrypted
  # and streamed to a ciphertext file.
  class EditVerse < Controller

    # This parental behaviour sets up common ubiquitous chapter and verse data structures
    # and indices. It then calls the child's query_verse() behaviour and once that is complete
    # it encrypts and persists an (updated) Book and the amended chapter.
    #
    # The streaming process also deletes the current (old) Book and chapter crypts.
    def execute

      # Before calling the edit_verse() method we perform some
      # preparatory activities that check, validate and setup.
      read_verse()

      # This is the expected edit() method that will do and deliver
      # the intented core contracted value proposition.
      edit_verse()

      # Now encrypt the changed verse and then write it out to a
      # chapter crypt file whilst garbage collecting the now spurious
      # and superceded script.
      update_verse()


    end


  end


end
