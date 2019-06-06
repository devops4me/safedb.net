#!/usr/bin/ruby
	
module SafeDb

  # The default action of the <b>keys use case</b> is to create a private and
  # public keypair and store them within the open chapter and verse.
  #
  # The optional keypair name parameter (if given) is used as a prefix to compose
  # the private and public key keynames. The prefix and descriptors will be period
  # separated.
  #
  # Currently the only algorithm used is the super secure EC (eliptic curve)
  # with 384 bits.
  #
  # == Generating Public Key for Unit Test
  #
  # To validate public key generation for SSH we can use the below command that
  # points to an on-disk private key file. The -y flag produces the magic.
  #
  #     ssh-keygen -f /path/to/private/key.pem -y
  #
  class Keys < EditVerse

    attr_writer :keypair_name

    # The <b>keypair use case</b> creates a private and public keypair and stores
    # them within the open chapter and verse.
    def edit_verse()

      keypair = Keypair.new()

      name_postfix = "" unless @keypair_name
      name_postfix = ".#{@keypair_name}" if @keypair_name
      bcv_name = "#{@book.book_name()}.#{@book.get_open_chapter_name()}.#{@book.get_open_verse_name()}#{name_postfix}"
      private_key_filename = "#{bcv_name}.private.key.pem"
      private_key_keyname = "#{Indices::PRIVATE_KEY_DEFAULT_KEY_NAME}#{name_postfix}"
      public_key_keyname = "#{Indices::PUBLIC_KEY_DEFAULT_KEY_NAME}#{name_postfix}"

      file_content64 = Base64.urlsafe_encode64( keypair.private_key_pem() )

      log.info(x) { "Keypair prefix => #{@keypair_name}" } if @keypair_name
      log.info(x) { "The keypair fully qualified name => [ #{private_key_filename} ]" }
      log.info(x) { "Keynames are [ #{private_key_keyname} ] and [ #{public_key_keyname} ]" }

      filedata_map = {}
      filedata_map.store( Indices::INGESTED_FILE_BASE_NAME_KEY, private_key_filename )
      filedata_map.store( Indices::INGESTED_FILE_CONTENT64_KEY, file_content64 )
      filedata_map.store( Indices::FILE_CHMOD_PERMISSIONS_KEY, "0600" )

      @verse.store( Indices::INGESTED_FILE_LINE_NAME_KEY + private_key_keyname, filedata_map )
      @verse.store( public_key_keyname, keypair.public_key_ssh() )

    end


  end


end
