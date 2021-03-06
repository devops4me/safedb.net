#!/usr/bin/ruby
	
module SafeDb

  # Parent to use cases like Init and Login that perform early
  # initialize workflows.
  class Authenticate < Controller

    # This authorization use case should always have a book name
    # provided and sometimes may have a password parameter.
    attr_writer :password, :book_name


    private


    # Return true if the human secret for the parameter application name
    # has been collected, transformed into a key, that key used to lock the
    # power key, then secret and keys deleted, plus a trail of breadcrumbs
    # sprinkled to allow the <b>branch crypt key to be regenerated</b>
    # at the <b>next login</b>.
    def is_book_initialized?()

      return false unless File.exists?( FileTree.master_book_indices_filepath(@book_name ) )
      data_map = DataMap.new( FileTree.master_book_indices_filepath(@book_name ) )
      return false unless data_map.has_section?( @book_name )
      data_map.use( @book_name )

      return contains_all_master_book_indices( data_map )

    end

    def contains_all_master_book_indices( data_map )
      return false unless data_map.contains?( Indices::CONTENT_RANDOM_IV )
      return false unless data_map.contains?( Indices::CONTENT_IDENTIFIER )
      return false unless data_map.contains?( Indices::CRYPT_CIPHER_TEXT )
      return false unless data_map.contains?( Indices::COMMIT_IDENTIFIER )
      return true
    end


  end


end


