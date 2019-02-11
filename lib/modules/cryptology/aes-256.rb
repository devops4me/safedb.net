#!/usr/bin/ruby
# coding: utf-8

module SafeDb

  module ToolBelt


  # Aes256 is a symmetric encryption cipher which inherits extends the
  # {SafeDb::Cipher} base class in order to implement plug and play
  # symmetric encryption.
  #
  # == Aes256 Symmetric Encrypt/Decrypt
  #
  # To facilitate decryption - this cipher produces a key/value pair
  # dictionary which will be stored along with the ciphertext itself.
  # The dictionary includes
  #
  # - <b>symmetric.cipher</b> - the algorithm used to encrypt and decrypt
  # - <b>encryption.key</b> - hex encoded key for encrypting and decrypting
  # - <b>initialize.vector</b> - the initialization vector known as a IV (four)
  #
  # == Aes256 Implemented Methods
  #
  # This cipher brings the cryptographic mathematics and implementation algorithms
  # for the 256Bit Advanced Encryption Standard. No serious practical (nor theoretical)
  # challenge has ever been mounted against this algorithm (or this implementation).
  #
  # This class implements the below methods
  #
  # - <b>do_symmetric_encryption(plain_text)</b> - resulting in ciphertext
  # - <b>do_symmetric_decryption(ciphertext, encryption_dictionary)</b> &raquo; plaintext
  #
  # and it also sets the <b>@dictionary</b> hash (map) of pertinent
  # key/value pairs including the +encryption algorithm+ and +encryption key+.
  #
  # That's It. Cipher children can rely on the {SafeDb::Cipher} parent to
  # do the nitty gritty of file-handling plus managing stores and paths.

  class Aes256

    # Use the AES 256 bit block cipher and a robust strong random key plus
    # initialization vector (IV) to symmetrically encrypt the plain text.
    #
    # <b>Cryptographic Properties</b>
    #
    # This encrypt event populates key/value pairs to the hash (dictionary) instance
    # given in the parameter.
    #
    # A crypt properties dictionary acts as <b>output from every encryption event</b>
    # and <b>input to every decryption event</b>. The most common properties include
    #
    # - the symmetric key used for the encryption and decryption
    # - the iv (initialization vector) that adds another dimension of strength
    # - authorization data that thwarts switch attacks by tying context to content
    # - the cipher algorithm, its implementation and its encryption strength
    # - the digest of the original message for validation purposes
    #
    # @param e_properties [Hash]
    #    instantiated hash map in which the encrryption properties will
    #    be stuffed.
    #
    # @param plain_text [String] the plain (or base64 encoded) text to encrypt
    # @return [String] the symmetrically encrypted cipher text
    def self.do_encrypt e_properties, plain_text

      crypt_cipher = OpenSSL::Cipher::AES256.new(:CBC)
      crypt_cipher.encrypt
      plain_text_digest = Digest::SHA256.digest plain_text

      e_properties[CryptIO::DICT_CIPHER_NAME] = crypt_cipher.class.name
      e_properties[CryptIO::DICT_CRYPT_KEY]   = Base64.urlsafe_encode64 crypt_cipher.random_key
      e_properties[CryptIO::DICT_CRYPT_IV]    = Base64.urlsafe_encode64 crypt_cipher.random_iv
      e_properties[CryptIO::DICT_TEXT_DIGEST] = Base64.urlsafe_encode64 plain_text_digest

      return crypt_cipher.update( plain_text ) + crypt_cipher.final

    end


    # Use the AES 256 bit block cipher together with the encryption key,
    # initialization vector (iv) and other data found within the decryption
    # properties dictionary to symmetrically decrypt the cipher text.
    #
    # This encrypt event in {self.do_encrypt} populated the property dictionary
    # that was presumably serialized, stored, retrieved then deserialized and
    # (at last) presented in the first parameter.
    #
    # <b>Cryptographic Properties</b>
    #
    # A crypt properties dictionary is the <b>output from every encryption event</b>
    # and <b>input to every decryption event</b>. The most common properties include
    #
    # - the symmetric key used for the encryption and decryption
    # - the iv (initialization vector) that adds another dimension of strength
    # - authorization data that thwarts switch attacks by tying context to content
    # - the cipher algorithm, its implementation and its encryption strength
    # - the digest of the original message for validation purposes
    #
    # @param d_properties [Hash]
    #    the crypt properties dictionary is the <b>output from every encryption event</b>
    #    and (as in this case) <b>input to every decryption event</b>.
    #
    # @param cipher_text [String]
    #    the (already decoded) cipher text for decryption by this method using the
    #    encryption properties setup during the past encrypt event.
    #
    # @return [String]
    #    the plain text message originally given to be encrypted. If the message digest
    #    is provided within the decryption properties dictionary a sanity check will
    #    occur.
    #
    # @raise [RuntimeError]
    #    if decryption fails or the recalculated message digest fails an equivalence test.
    def self.do_decrypt d_properties, cipher_text

      decode_cipher = OpenSSL::Cipher::AES256.new(:CBC)
      decode_cipher.decrypt

      decode_cipher.key = Base64.urlsafe_decode64( d_properties[CryptIO::DICT_CRYPT_KEY] )
      decode_cipher.iv  = Base64.urlsafe_decode64( d_properties[CryptIO::DICT_CRYPT_IV]  )

      plain_text = decode_cipher.update( cipher_text ) + decode_cipher.final
      assert_digest_equivalence( d_properties[CryptIO::DICT_TEXT_DIGEST], plain_text )

      return plain_text

    end


    private


    def self.assert_digest_equivalence( digest_b4_encryption, plain_text_message )

      plain_text_digest = Base64.urlsafe_encode64( Digest::SHA256.digest( plain_text_message ) )
      return if digest_b4_encryption.eql? plain_text_digest

      msg1 = "\nEquivalence check of original and decrypted plain text digests failed.\n"
      msg2 = "Digest before encryption => #{digest_b4_encryption}\n"
      msg3 = "Digest after decryption  => #{plain_text_digest}\n"
      error_message = msg1 + msg2 + msg3
      raise RuntimeError, error_message

    end


  end


  end


end
