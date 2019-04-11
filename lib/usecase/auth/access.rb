#!/usr/bin/ruby
	
module SafeDb

  # Parent to use cases like Init and Login that perform early
  # initialize workflows.
  class AccessUc < UseCase

    attr_writer :password, :book_name


    private


    # Return true if the human secret for the parameter application name
    # has been collected, transformed into a key, that key used to lock the
    # power key, then secret and keys deleted, plus a trail of breadcrumbs
    # sprinkled to allow the <b>branch crypt key to be regenerated</b>
    # at the <b>next login</b>.
    def is_book_initialized?()

      KeyError.not_new( @book_name, self )
      return false unless File.exists?( Indices::MASTER_INDICES_FILEPATH )
      data_map = DataMap.new( Indices::MASTER_INDICES_FILEPATH )
      return false unless data_map.has_section?( @book_id )
      data_map.use( @book_id )

      return contains_all_master_book_indices( data_map )

    end


    def contains_all_master_book_indices( data_map )
      return false unless data_map.contains?( Indices::CONTENT_RANDOM_IV )
      return false unless data_map.contains?( Indices::CONTENT_IDENTIFIER )
      return false unless data_map.contains?( Indices::MASTER_KEY_CRYPT )
      return false unless data_map.contains?( Indices::MASTER_COMMIT_ID )
      return true
    end


  end


end


