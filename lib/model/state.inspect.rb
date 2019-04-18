#!/usr/bin/ruby

module SafeDb

  # State queries are related to {StateMigrate} but they simple ask for information
  # about the state without changing any state.
  #
  class StateInspect


=begin

---
--- safe diff --checkin
--- outgoing from branch into master
---

---
--- safe diff --checkout
--- incoming from master into branch
---
 + Line to be added ->
 + Chapter 2b added ->
 + Verse 2 be added ->
 / Line will change ->

 - Line to be removed ->
 - Chapter 2b removed ->
 - Verse 2 be removed ->

=end

    def self.to_checkout_diff_report( book )

      master_data = book.to_master_data()
      branch_data = book.to_branch_data()


      master_data.each_pair do | chapter_name, master_verse_data |
        
        has_chapter = branch_data.has_key?( chapter_name )
        puts "Chapter [ #{chapter_name} ] will be added to branch." unless has_chapter
        if( has_chapter )
          
          branch_verse_data = branch_data[ chapter_name ]
          master_verse_data.each_pair do | verse_name, master_line_data |

            has_verse = branch_verse_data.has_key?( verse_name )
            puts "Verse [ #{chapter_name}/#{verse_name} ] will be added to branch." unless has_verse
            if( has_verse )

              branch_line_data = branch_verse_data[ verse_name ]
              master_line_data.each_pair do | line_name, master_line_value |

                has_line = branch_line_data.has_key?( line_name )
                puts "Line [ #{chapter_name}/#{verse_name}/#{line_name} ] will be added to branch." unless has_line
                if( has_line )

                  branch_line_value = branch_line_data[ line_name ]
                  lines_equal = master_line_value == branch_line_value
                  puts "Line [ #{chapter_name}/#{verse_name}/#{line_name} ] will be changed." unless lines_equal

                end

              end

            end

          end

        end


      end

      puts JSON.pretty_generate( master_data )
      puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
      puts JSON.pretty_generate( branch_data )

      puts ""
      puts "The master has #{master_data.length()} chapters and #{book.get_master_verse_count()} verses.\n"
      puts "The branch has #{branch_data.length()} chapters and #{book.get_branch_verse_count()} verses.\n"
      puts ""

    end



    # Returns true if valid credentials have been provided earlier on in this
    # session against the book specified in the parameter.
    #
    # Note the "in-use" concept. Even when specified book is not currently
    # in use, true may be returned (as long as a successful login occured).
    #
    # @param book_id [String] book identifier that login request is against
    # @return [Boolean] true if the parameter book is currently logged in
    def self.is_logged_in?( book_id )
      
      branch_id = Identifier.derive_branch_id( Branch.to_token() )
      return false unless File.exists?( FileTree.branch_indices_filepath( branch_id ) )
      branch_keys = DataMap.new( FileTree.branch_indices_filepath( branch_id ) )
      return false unless branch_keys.has_section?( Indices::BRANCH_DATA )
      return false unless branch_keys.has_section?( book_id )

      branch_keys.use( book_id )
      branch_key_ciphertext = branch_keys.get( Indices::CRYPT_CIPHER_TEXT )
      branch_key = KeyDerivation.regenerate_shell_key( Branch.to_token() )

      begin
        branch_key.do_decrypt_key( branch_key_ciphertext )
        return true
      rescue OpenSSL::Cipher::CipherError => e
        log.warn(x) { "A login check against book #{book_id} has failed." }
        log.warn(x) { "Login failure error message is #{e.message}" }
        return false
      end

    end


    # Have any logins to this safe book occured since the machine was last
    # rebooted? If no, true is returned. If another login has already occurred
    # since the reboot false is returned.
    #
    # This method examines the bootup ID and if one exists and is equivalent
    # to the current one, false is returned. Otherwise true is returned.
    #
    # Set the booup identifier within the parameter key/value map under the
    # globally recognized {Indices::BOOTUP_IDENTIFIER} constant. This method
    # expects the {DataMap} section name to be a significant identifier.
    #
    # @param data_map [DataMap] the data map in which we set the bootup id
    # @return [Boolean] true if this is the first book login since bootup
    def self.is_first_login?( data_map )
      
      return true unless data_map.contains?( Indices::BOOTUP_IDENTIFIER )
      old_bootup_id = data_map.get( Indices::BOOTUP_IDENTIFIER )
      new_bootup_id = MachineId.get_bootup_id()
      return old_bootup_id != new_bootup_id

    end


  end


end
