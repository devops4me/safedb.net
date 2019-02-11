#!/usr/bin/ruby
# coding: utf-8

module SafeDb

  module ToolBelt

    require "base64"

    # {SafeDb::Cipher} is a base class that enables cipher varieties
    # to be plugged and played with minimal effort. This Cipher implements much
    # of the use case functionality - all extension classes need to do, is
    # to subclass and implement only the core behaviour that define its identity.
    #
    # == Double Encryption | Cipher Parent vs Cipher Child
    #
    # Double encryption first with a symmetric and then an asymmetric one fulfills
    # the +safe+ promise of making the stored ciphertext utterly worthless.
    #
    # The child ciphers implement the inner symmetric encyption whilst the parent
    # implements the outer asymmetric encryption algorithm.
    #
    # The process is done twice resulting in two stores that are mirrored in structure.
    # The front end store holds doubly encrypted keys whist the backend store holds
    # the doubly encrypted secrets.
    #
    # Attackers wouldn't be able to distinguish one from the other. Even if they
    # theoretically cracked the asymmetric encryption - they would then be faced
    # with a powerful symmetric encryption algorithm which could be any one of the
    # leading ciphers such as TwoFish or the Advanced Encryption Standard (AES).
    #
    # == Ciphers at 3 Levels
    #
    # Ciphers are implemented at three distinct levels.
    #
    # <b>Low Level Ciphers</b>
    #
    # Low level ciphers are given text to encrypt and an instantiated dictionary
    # in which to place the encryption parameters such as keys and initialization
    # vectors (iv)s.
    #
    # Some more specific ciphers can handle authorization data for example the
    # Galois Counter Mode (GCM) cipher.
    #
    # Low level ciphers know nothing about text IO nor reading and writing to
    # persistence structures like files, queues and databases.
    #
    # <b>Mid Level Ciphers</b>
    #
    # Mid level ciphers talk to the low level ciphers and bring in input and output
    # textual formats like SafeDb's two-part block structures.
    #
    # Mid level ciphers still know nothing of persistence structures like files,
    # queues and databases.
    #
    # <b>Use Case Level Ciphers</b>
    #
    # The ciphers operating at the use case level talk to mid level ciphers. They
    # interact with the <b>safe store API</b> which brings persistence
    # functions such as <b>read/write</b> as well as remoting functions such as
    # <b>push/pull</b>.
    #
    # Use Case level ciphers interact with the latest crypt technologies due to
    # interface separation. Also they talk classes implementing persistence stores
    # allowing assets liek Git, S3, DropBox, simple files, SSH filesystems, Samba
    # to hold locked key and material crypts.
    #
    # Databases stores will be introduced soon allowing safe to plug in and
    # exploit database managers like Mongo, Hadoop, MySQL, Maria, and PostgreSQL.
    #
    # Plugging into DevOps orchestration platforms like Terraform, Ansible, Chef
    # and Puppet will soon be available. Add this with integrations to other credential
    # managers like HashiCorp's Vault, Credstash, Amazon KMS, Git Secrets, PGP,
    # LastPass, KeePass and KeePassX.
    #
    # == How to Implement a Cipher
    #
    # Extend this base class to inherit lots of +unexciting+ functionality
    # that essentially
    #
    # - manages the main encryption and decryption use case flow
    # - +concatenates+ the symmetric encryption meta data with ciphertext +after encryption+
    # - _splits_ and objectifies the key/value metadata plus ciphertext +before decryption+
    # - +handles file read/writes+ in conjunction with the store plugins
    # - handles +exceptions+ and +malicious input detection+ and incubation
    # - +_performs the asymmetric encryption_+ of the cipher's symmetrically encrypted output
    #
    # == What Behaviour Must Ciphers Implement
    #
    # Ciphers bring the cryptographic mathematics and implementation algorithms
    # to the table. So when at home they must implement
    #
    # - <tt>do_symmetric_encryption(plain_text)</tt> - resulting in ciphertext
    # - <tt>do_symmetric_decryption(ciphertext, encryption_dictionary)</tt> &raquo; plaintext
    #
    # and also set the <tt>@dictionary</tt> hash (map) of pertinent
    # key/value pairs including the encryption algorithm, the encryption key and
    # the ciphertext signature to thwart any at-rest tampering.
    #
    # That's It. Cipher children can rely on the {SafeDb::Cipher} parent to
    # do the nitty gritty of file-handling plus managing stores and paths.
    class Cipher

      # Ciphers use <b>symmetric algorithms</b> to encrypt the given text, which
      # is then wrapped up along with the encryption key and other <b>metadata</b>
      # pertinent to the algorithm, they then encrypt this bundle with the
      # <b>public key</b> provided and return the text that can safely be stored in
      # a text file.
      #
      # Ciphers should never interact with the filesystem which makes them
      # reusable in API and remote store scenarios.
      #
      # Binary files should be converted into the base64 format before being
      # presented to ciphers.
      #
      # Every component in the pipeline bears the responsibility for nullifying
      # and rejecting malicious content.
      #
      # @param public_key [OpenSSL::PKey::RSA]
      #    an {OpenSSL::PKey::RSA} public key. The unique selling point of
      #    asymmetric encryption is it can be done without recourse to the heavily
      #    protected private key. Thus the encryption process can continue with
      #    just a public key as long as its authenticity is assured.
      #
      # @param payload_text [String]
      #    plaintext (or base64 encoded) text to encrypt
      #
      # @return [String] doubly (symmetric and asymmetric) encrypted cipher text
      def self.encrypt_it public_key, payload_text

        crypt_data = {}
        crypted_payload = Base64.encode64( Aes256.do_encrypt( crypt_data, payload_text ) )
        unified_material = CryptIO.inner_crypt_serialize crypt_data, crypted_payload

        outer_crypt_key = Engineer.strong_key( 128 )
        crypted_cryptkey = Base64.encode64( public_key.public_encrypt( outer_crypt_key ) )

        crypted_material = Base64.encode64(Blowfish.encryptor unified_material, outer_crypt_key)

        return CryptIO.outer_crypt_serialize( crypted_cryptkey, crypted_material )

      end


      # This method takes and <b><em>safe formatted</em></b> cipher-text block
      # generated by {self.encrypt_it} and returns the original message that has effectively
      # been doubly encrypted using a symmetric and asymmetric cipher. This type of
      # encryption is standard best practice when serializing secrets.
      #
      # safe cipher-text blocks <b><em>look like a two(2) part bundle</em></b>
      # but they are <b><em>actually a three(3) part bundle</em></b> because the second
      # part is in itself an amalgam of two distinct objects, serialized as text blocks.
      #
      # <b>The 3 SafeDb Blocks</b>
      #
      # Even though the incoming text <b><em>appears to contain two (2) blocks</em></b>,
      # it <b><em>actually contains three (3)</em></b>.
      #
      # - a massive symmetric encryption key (locked by an asymmetric keypair)
      # - a dictionary denoting the algorithm and parameters used to encrypt the 3rd block
      # - the true message whose encryption is parametized by the dictionary (in 2nd block)
      #
      # The second and third block are only revealed by asymmetrically decrypting
      # the key in the first block and using it to symmetrically decrypt what appears
      # to be a unified second block.
      #
      # @param private_key [OpenSSL::PKey::RSA]
      #    the <b>asymmetric private key</b> whose corresponding public key was
      #    employed during the encryption of a super-strong 128 character symmetric
      #    key embalmed by the first ciphertext block.
      #
      # @param os_block_text [String]
      #    the locked cipher text is the safe formatted block which comes
      #    in two main chunks. First is the <b>long strong</b> symmetric encryption
      #    key crypted with the public key portion of the private key in the first
      #    parameter.
      #
      #    The second chunk is the symmetrically crypted text that was locked with
      #    the encryption key revealed in the first chunk.
      #
      # @return [String]
      #    the doubly encrypted plain text that is locked by a symmetric key and
      #    that symmetric key itself locked using the public key portion of the
      #    private key whose crypted form is presented in the first parameter.
      def self.decrypt_it private_key, os_block_text

        first_block = Base64.decode64( CryptIO.outer_crypt_deserialize os_block_text, true  )
        trail_block = Base64.decode64( CryptIO.outer_crypt_deserialize os_block_text, false )

        decrypt_key = private_key.private_decrypt first_block
        inner_block = Blowfish.decryptor( trail_block, decrypt_key )

        crypt_props = Hash.new
        cipher_text = CryptIO.inner_crypt_deserialize( crypt_props, inner_block )

        return Aes256.do_decrypt( crypt_props, cipher_text )

      end


    end


  end


end
