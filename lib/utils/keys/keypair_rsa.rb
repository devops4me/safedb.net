#!/usr/bin/ruby
# coding: utf-8

module SafeDb

  # This class creates and represents a RSA cryptographic public/private key.
  # The generated key can then be comsumed via its various aspects like its
  # ssh formatted public key and/or the pem formatted private key.
  class KeypairRSA

    # Generate a RSA cryptographic public/private keypair. After the key is
    # generated, both the public and private keys can be retrieved through
    # the accessors.
    def initialize

      @rsa_keypair = OpenSSL::PKey::RSA.new(4096)
      log.info(x) { "An RSA public/private keypair has just been generated." }

    end


    # Get the private key aspect of this RSA cryptographic key in PEM format.
    #
    # @return [String] the PEM formatted private key
    def private_key_pem()
      return @rsa_keypair.to_pem()
    end


    # Get the public key aspect of this RSA public/private cryptographic key
    # in the long line SSH format. This format states the key type which will
    # be **ecdsa-sha2-nistp384** followed by base64 encoded data.
    #
    # The returned one line public key will likely contain forward slashes
    # and possibly equal signs at the end of the string.
    #
    # @return [String] the SSH formatted public key prefixed by the key type
    def public_key_ssh()
      require 'net/ssh'
      key_type = @rsa_keypair.ssh_type()
      key_data = [ @rsa_keypair.to_blob ].pack('m0')
      return "#{key_type} #{key_data}"
    end


  end


end
