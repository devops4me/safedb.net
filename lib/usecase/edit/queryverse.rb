#!/usr/bin/ruby
	
module SafeDb

  # Any {UseCase} class wishing to query a safe verse can make use of the functionality
  # in this parent by exposing an query_verse() method.
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
  # The query_verse() method is not succeeded by any behaviour in the parent. Chilc classes
  # must do their own output management.
  class QueryVerse < UseCase

    # This parental behaviour sets up common ubiquitous chapter and verse data structures
    # and indices.
    def execute

      # Before calling the edit_verse() method we perform some
      # preparatory activities that check, validate and setup.
      read_verse()

      # The query verse behaviour implemented by the child classes will read and
      # perhaps display credentials without changing state.
      query_verse()

    end


  end


end
