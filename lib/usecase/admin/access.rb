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
    # sprinkled to allow the <b>inter-sessionary key to be regenerated</b>
    # at the <b>next login</b>.
    def is_book_initialized?()

      KeyError.not_new( @book_name, self )
      return false unless File.exists?( MASTER_INDEX_LOCAL_FILE )
      key_map = KeyMap.new( MASTER_INDEX_LOCAL_FILE )
      return false unless key_map.has_section?( @book_id )
      key_map.use( @book_id )

      return Lock.contains_all_master_book_indices( key_map )

    end


  end


end


