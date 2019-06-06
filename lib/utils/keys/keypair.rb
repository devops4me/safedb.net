#!/usr/bin/ruby
# coding: utf-8

module SafeDb

  # This class creates and represents an Elliptic Curve cryptographic key.
  # The generated key can then be comsumed via its various aspects like its
  # ssh formatted public key and/or the pem formatted private key.
  class Keypair

    # Generate an elliptic curve cryptographic keypair. After the key is
    # generated, both the public and private keys can be retrieved through
    # the accessors.
    #
    def initialize

      @ec_keypair = OpenSSL::PKey::EC.new( Indices::ELLIPTIC_CURVE_KEY_TYPE )
      @ec_keypair.generate_key!

      log.info(x) { "An elliptic curve keypair has just been generated." }

    end


    # Get the private key aspect of this elliptic curve cryptographic key
    # in PEM format.
    # @return [String] the PEM formatted private key
    def private_key_pem()
      return @ec_keypair.to_pem()
    end


    # Get the public key aspect of this elliptic curve cryptographic key
    # in the long line SSH format. This format states the key type which
    # will be **ecdsa-sha2-nistp384** followed by base64 encoded data.
    #
    # The returned one line public key will likely contain forward slashes
    # and possibly equal signs at the end of the string.
    #
    # @return [String] the SSH formatted public key prefixed by the key type
    def public_key_ssh()
      require 'net/ssh'
      key_type = @ec_keypair.ssh_type()
      key_data = [ @ec_keypair.to_blob ].pack('m0')
      return "#{key_type} #{key_data}"
    end


  end


end
