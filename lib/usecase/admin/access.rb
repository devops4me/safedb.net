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
      keypairs = KeyMap.new( MACHINE_CONFIG_FILE )
      aim_id = KeyId.derive_app_instance_machine_id( @book_name )
      app_id = KeyId.derive_app_instance_identifier( @book_name )
      keypairs.use( aim_id )

      keystore_file = get_keystore_file_from_domain_name( @book_name )
      return false unless File.exists?( keystore_file )

      crumbs_db = KeyMap.new( keystore_file )
      return false unless crumbs_db.has_section?( APP_KEY_DB_BREAD_CRUMBS )
      
      crumbs_db.use( APP_KEY_DB_BREAD_CRUMBS )
      return crumbs_db.contains?( INTER_KEY_CIPHERTEXT )

    end


  end


end


