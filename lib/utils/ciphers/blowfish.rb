#!/usr/bin/ruby
# coding: utf-8

module SafeDb

  module ToolBelt

    # Blowfish is a symmetric encryption cipher which inherits extends the
    # {SafeDb::Cipher} base class in order to implement plug and play
    # symmetric encryption.
    #
    # Blowfish is still uncrackable - however its successor (TwoFish) has
    # been reinforced to counter the growth of super-computer brute force
    # resources.
    class Blowfish

      # The blowfish cipher id constant is used to +initialize+
      # an {OpenSSL::Cipher} class instance.
      BLOWFISH_CIPHER_ID = "BF-ECB"


      # Blowfish constrains the length of +incoming plain text+ forcing it
      # to be a multiple of eight (8).
      BLOWFISH_BLOCK_LEN = 8


      # Encrypt the (plain) text parameter using the symmetric encryption key
      # specified in the second parameter and return the base64 encoded
      # representation of the cipher text.
      #
      # Blowfish is a block cipher meaning it needs both the key and the plain
      # text inputted to conform to a divisible block length.
      #
      # Don't worry about this block length requirement as this encrption method
      # takes care of it and its sister method {self.decryptor} will also perform
      # the correct reversal activities to give you back the original plain text.
      #
      # {Base64.urlsafe_encode64} facilitates the ciphertext encoding returning text that
      # is safe to write to a file.
      #
      # @param plain_text [String]
      #    This parameter should be the non-nil text to encrypt using Blowfish.
      #    Before encryption the text will be padded using a text string from
      #    the {SafeDb::Cipher::TEXT_PADDER} constant until it results in
      #    a string with the required block length.
      #
      # @param encryption_key [String]
      #    send a long strong unencoded key which does not have to be a multiple of
      #    eight even though the algorithm demands it. Before the encryption this key
      #    will be passed through a digest using behaviour from {Digest::SHA256.digest}
      #
      #    This behaviour returns a key whose length is a multiple of eight.
      #
      # @return [String] base64 representation of blowfish crypted ciphertext
      #
      # @raise [OpenSSL::Cipher::CipherError]
      #    An (encryption) <tt>key length too short</tt> error is raised for short keys.
      def self.encryptor plain_text, encryption_key

        shortkey_msg = "The #{encryption_key.length} character encryption key is too short."
        raise ArgumentError, shortkey_msg unless encryption_key.length > 8
        log.info(x) { "os blowfish request to encrypt plain text with provided key." }

        block_txt = plain_text
        block_txt += CryptIO::TEXT_PADDER until block_txt.bytesize % BLOWFISH_BLOCK_LEN == 0
        raw_stretched_key = Digest::SHA256.digest(encryption_key)

        blowfish_encryptor = OpenSSL::Cipher.new(BLOWFISH_CIPHER_ID).encrypt
        blowfish_encryptor.key = raw_stretched_key
        return blowfish_encryptor.update(block_txt) << blowfish_encryptor.final

      end


      # Decrypt the cipher text parameter using the symmetric decryption key
      # specified in the second parameter. The cipher text is expected to have
      # already been decoded if necessary.
      #
      # Its okay to use a bespoke encryptor - just ensure you encode the result
      # and override the padding constant.
      #
      # Blowfish is a block cipher meaning it needs both the key and the plain
      # text inputted to conform to a divisible block length.
      #
      # Don't worry about this block length requirement as this decrption method
      # takes care of the reversing the activities carried out by {self.encryptor}.
      #
      # @param cipher_text [String]
      #    This incoming cipher text should already be encoded but it
      #    will <b>chomped and stripped upon receipt</b> followed by
      #    decryption using the Blowfish algorithm.
      #
      # @param decryption_key [String]
      #    Send the same key that was used during the encryption phase. The encryption
      #    phase passed the key through the {Digest::SHA256.digest} digest so here
      #    the decryption does the exact same thing.
      #
      #    The digest processing guarantees a symmetric key whose length conforms to
      #    the multiple of eight block length requirement.
      #
      # @return [String]
      #    After decoding and decryption the plain text string will still be padded,
      #    +but not with spaces+. The unlikely to occur padding string constant used
      #    is the {SafeDb::Cipher::TEXT_PADDER}.
      #
      #    If the plaintext ended with spaces these would be preserved. After padder
      #    removal any trailing spaces will be preserved in the returned plain text.
      #
      def self.decryptor cipher_text, decryption_key

        digested_key = Digest::SHA256.digest decryption_key

        decrypt_tool = OpenSSL::Cipher.new(BLOWFISH_CIPHER_ID).decrypt
        decrypt_tool.key = digested_key

        padded_plaintxt = decrypt_tool.update(cipher_text) << decrypt_tool.final
        pad_begin_index = padded_plaintxt.index CryptIO::TEXT_PADDER
        return padded_plaintxt if pad_begin_index.nil?
        return padded_plaintxt[ 0 .. (pad_begin_index-1) ]

      end


    end


  end


end
