#!/usr/bin/ruby
	
module SafeDb

  # Parent to use cases like Init and Login that perform early
  # initialize workflows.
  class AccessUc < UseCase

    attr_writer :password, :domain_name

    # Return true if the human secret for the parameter application name
    # has been collected, transformed into a key, that key used to lock the
    # power key, then secret and keys deleted, plus a trail of breadcrumbs
    # sprinkled to allow the <b>inter-sessionary key to be regenerated</b>
    # at the <b>next login</b>.
    def self.is_book_initialized?( domain_name )

##################### Change this and put in some REAL logic
##################### Change this and put in some REAL logic
##################### Change this and put in some REAL logic
##################### Change this and put in some REAL logic
##################### Change this and put in some REAL logic
##################### Change this and put in some REAL logic
##################### Change this and put in some REAL logic

      return false


##################### Change this and put in some REAL logic
##################### Change this and put in some REAL logic
##################### Change this and put in some REAL logic


      KeyError.not_new( domain_name, self )
      keypairs = KeyPair.new( MACHINE_CONFIG_FILE )
      aim_id = KeyId.derive_app_instance_machine_id( domain_name )
      app_id = KeyId.derive_app_instance_identifier( domain_name )
      keypairs.use( aim_id )

      keystore_file = get_keystore_file_from_domain_name( domain_name )
      return false unless File.exists?( keystore_file )

      crumbs_db = KeyPair.new( keystore_file )
      return false unless crumbs_db.has_section?( APP_KEY_DB_BREAD_CRUMBS )
      
      crumbs_db.use( APP_KEY_DB_BREAD_CRUMBS )
      return crumbs_db.contains?( INTER_KEY_CIPHERTEXT )

    end


  end


end


