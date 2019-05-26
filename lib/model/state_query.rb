#!/usr/bin/ruby

module SafeDb

  # State queries are related to {EvolveState} but they simple ask for information
  # about the state without changing any state.
  #
  class StateInspect

    # Return true if this book has been logged in during this session.
    # @return [Boolean] true if not logged into this book
    def self.not_logged_in?()

      branch_id = Identifier.derive_branch_id( Branch.to_token() )
      return true unless File.exists?( FileTree.branch_indices_filepath( branch_id ) )
      branch_keys = DataMap.new( FileTree.branch_indices_filepath( branch_id ) )
      return true unless branch_keys.has_section?( Indices::BRANCH_DATA )
      book_id = branch_keys.read( Indices::BRANCH_DATA, Indices::CURRENT_BRANCH_BOOK_ID )
      return true unless branch_keys.has_section?( book_id )
      return !is_logged_in?( book_id )

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

      return branch_key.can_decrypt_key( branch_key_ciphertext )

=begin
      begin
        branch_key.do_decrypt_key( branch_key_ciphertext )
        return true
      rescue OpenSSL::Cipher::CipherError => e
        log.warn(x) { "A login check against book #{book_id} has failed." }
        log.warn(x) { "Login failure error message is #{e.message}" }
        return false
      end
=end

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


    # A refresh is effectively an incoming merge of the master's data
    # structure into the working branch. With refreshs nothing ever gets
    # deleted.
    #
    # No delete is self-evident in this list of only <tt>4 prophetic</tt>
    # outcomes
    #
    # - this chapter will be added
    # - this verse will be added
    # - this line will be added
    # - this branch's line value will be overwritten with the value from master
    #
    # Examine the sister method {commit_diff} that prophesizes on the
    # state changes a commit will invoke.
    #
    # @param master_data [Hash] data structure from the master line of the book
    # @param branch_data [Hash] data structure from the current working branch
    def self.refresh_prophecies( master_data, branch_data )
      data_differences( master_data, branch_data )
    end


    # A refresh merges whilst a commit is effectively a hard copy that destroys
    # whatever is on the master making it exactly reflect the branch's current state.
    #
    # The three addition state changes prophesized by a refresh can also occur on
    # commits. However commits can also prophesize that
    #
    # - this master's line value will be overwritten with the branch's value
    # - this chapter will be removed
    # - this verse will be removed
    # - this line will be removed
    #
    # Examine the sister method {commit_diff} that prophesizes on the
    # state changes a commit will invoke.
    #
    # @param master_data [Hash] data structure from the master line of the book
    # @param branch_data [Hash] data structure from the current working branch
    def self.commit_prophecies( master_data, branch_data )
      data_differences( branch_data, master_data )
      drop_differences( master_data, branch_data )
    end



    private



    def self.data_differences( this_data, that_data )

      this_data.each_pair do | chapter_name, master_verse_data |
        
        has_chapter = that_data.has_key?( chapter_name )
        print_chapter_2b_added( chapter_name ) unless has_chapter
        next unless has_chapter
          
        branch_verse_data = that_data[ chapter_name ]
        master_verse_data.each_pair do | verse_name, master_line_data |

          has_verse = branch_verse_data.has_key?( verse_name )
          print_verse_2_be_added( "#{chapter_name}/#{verse_name}" ) unless has_verse
          next unless has_verse

          branch_line_data = branch_verse_data[ verse_name ]
          master_line_data.each_pair do | line_name, master_line_value |

            has_line = branch_line_data.has_key?( line_name )
            print_line_to_be_added( "#{chapter_name}/#{verse_name}/#{line_name}" ) unless has_line
            next unless has_line

            branch_line_value = branch_line_data[ line_name ]
            lines_equal = master_line_value == branch_line_value
            print_line_will_change( "#{chapter_name}/#{verse_name}/#{line_name}" ) unless lines_equal

          end

        end

      end

    end


    def self.drop_differences( this_data, that_data )

      this_data.each_pair do | chapter_name, master_verse_data |
        
        has_chapter = that_data.has_key?( chapter_name )
        print_chapter_2b_removed( chapter_name ) unless has_chapter
        next unless has_chapter
          
        branch_verse_data = that_data[ chapter_name ]
        master_verse_data.each_pair do | verse_name, master_line_data |

          has_verse = branch_verse_data.has_key?( verse_name )
          print_verse_2_be_removed( "#{chapter_name}/#{verse_name}" ) unless has_verse
          next unless has_verse

          branch_line_data = branch_verse_data[ verse_name ]
          master_line_data.each_pair do | line_name, master_line_value |

            has_line = branch_line_data.has_key?( line_name )
            print_line_to_be_removed( "#{chapter_name}/#{verse_name}/#{line_name}" ) unless has_line

          end

        end

      end

    end


    def self.print_chapter_2b_added( fq_chap_name )
      puts "     + Chapter 2b added -> #{fq_chap_name}"
    end

    def self.print_verse_2_be_added( fq_vers_name )
      puts "     + Verse 2 be added -> #{fq_vers_name}"
    end

    def self.print_line_to_be_added( fq_line_name )
      puts "     + Line to be added -> #{fq_line_name}"
    end

    def self.print_line_will_change( fq_line_name )
      puts "     + Line will change -> #{fq_line_name}"
    end

    def self.print_chapter_2b_removed( fq_chap_name )
      puts "     - Chapter 2b removed -> #{fq_chap_name}"
    end

    def self.print_verse_2_be_removed( fq_vers_name )
      puts "     - Verse 2 be removed -> #{fq_vers_name}"
    end

    def self.print_line_to_be_removed( fq_line_name )
      puts "     - Line to be removed -> #{fq_line_name}"
    end


  end


end
