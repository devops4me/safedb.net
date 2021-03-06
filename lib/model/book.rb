#!/usr/bin/ruby

module SafeDb

  # The book index is pretty much like the index at the front of a book!
  #
  # With a real book the index tells you the page number of a chapter. Our Book
  # knows about and behaves with concepts like
  #
  # - the list of chapters in the book including the chapter names
  # - attributes like book name, creation and last accessed dates
  # - book scoped configuration directives and their values
  # - chapter keys including file content ids and encryption keys
  #
  # Parental use cases in the background will use this index to encrypt, decrypt
  # create, read, update and delete chapter encased credentials.
  #
  class Book


    # Initialize the book index data structure from the branch state file
    # and the current branch identifier.
    #
    # We assume that something else created the very first book index so we
    # never check whether it exists, instead we assume that one does exist.
    def initialize

      @branch_id = Identifier.derive_branch_id( Branch.to_token() )
      @branch_keys = DataMap.new( FileTree.branch_indices_filepath( @branch_id ) )
      @book_id = @branch_keys.read( Indices::BRANCH_DATA, Indices::CURRENT_BRANCH_BOOK_ID )
      @branch_keys.use( @book_id )
      @content_id = @branch_keys.get( Indices::CONTENT_IDENTIFIER )

      @master_keys = DataMap.new( FileTree.master_book_indices_filepath( @book_id ) )
      @master_keys.use( @book_id )

      intra_key_ciphertext = @branch_keys.get( Indices::CRYPT_CIPHER_TEXT )
      intra_key = KeyDerivation.regenerate_shell_key( Branch.to_token() )
      @crypt_key = intra_key.do_decrypt_key( intra_key_ciphertext )

      read()

    end


    # Get the hash data structure representing the master's state. This state
    # may or may not be equivalent to the current branch state as gettable by
    # the {to_branch_data} method.
    def to_master_data()

      set_master_chapter_keys()
      @master_data = {}
      @master_verse_count = 0

      @master_chapter_keys.each_pair do | chapter_name, chapter_indices |
        master_chapter_data = Content.unlock_master_chapter( @book_id, chapter_indices )
        @master_data.store( chapter_name, master_chapter_data )
        @master_verse_count += master_chapter_data.length()
      end

      return @master_data

    end

    # Get the number of verses in the master's data structure.
    # @return [Number] the number of verses in the master's data.
    def get_master_verse_count()
      return @master_verse_count
    end


    # Get the hash data structure representing the branch's state. This state
    # may or may not be equivalent to the current master state as gettable by
    # the {to_master_data} method.
    def to_branch_data()

      @branch_data = {}
      @branch_verse_count = 0

      branch_chapter_keys().each_pair do | chapter_name, chapter_keys |

        branch_chapter_data = Content.unlock_branch_chapter( chapter_keys )
        @branch_data.store( chapter_name, branch_chapter_data )
        @branch_verse_count += branch_chapter_data.length

      end

      return @branch_data

    end


    # Get the number of verses in the branch's data structure.
    # @return [Number] the number of verses in the branch's data.
    def get_branch_verse_count()
      return @branch_verse_count
    end



    # Construct a Book object that extends the DataStore data structure
    # which in turns extens the Ruby hash object. The parental objects know
    # how to manipulate (store, delete, read etc the data structures).
    #
    # To read the book index we first find the appropriate shell key and the
    # appropriate book index ciphertext, one decrypts the other to produce the master
    # database decryption key which in turn reveals the JSON representation of the
    # master database.
    #
    # The {DataMap} book index JSON is streamed into one of the crypt files denoted by
    # a content identifier - this file is decrypted and the data structure deserialized
    # into a {Hash} and returned.
    #
    # <b>Steps Taken To Read the Master Database</b>
    #
    # Reading up and returning the master database requires a rostra of actions namely
    #
    # - finding the branch data and reading the ID of the book in play
    # - using the content id, branch id and book id to locate the crypt file
    # - using the branch shell key and salt to unlock the content encryption key
    # - using the content crypt key and random iv to unlock the file's ciphertext
    #
    # @return [String]
    #    decode, decrypt and hen return the plain text content that was written
    #    to a file by the {write_content} method.
    def read()

      read_crypt_path = FileTree.branch_crypts_filepath( @book_id, @branch_id, @content_id )
      random_iv = KeyIV.in_binary( @branch_keys.get( Indices::CONTENT_RANDOM_IV ) )
      @book = DataStore.from_json( Content.unlock_it( read_crypt_path, @crypt_key, random_iv ) )

    end


    # This write content behaviour takes the parameter content, encyrpts and
    # encodes it using the index key, which is itself derived from the shell
    # key unlocking the intra branch ciphertext. The crypted content is
    # written to a file whose path is derviced by {content_ciphertxt_file_from_domain_name}.
    #
    # <b>Steps Taken To Write the Content</b>
    #
    # Writing the content requires a rostra of actions namely
    #
    # - deriving filepaths to both the breadcrumb and ciphertext files
    # - creating a random iv and adding its base64 form to the breadcrumbs
    # - using the shell token to derive the (unique to the) shell key
    # - using the shell key and (intra) ciphertext to acquire the index key
    # - using the index key and random iv to encrypt and encode the content
    # - writing the resulting ciphertext to a file at the designated path
    #
    # <b>In with the new then out with the old</b>
    #
    # Once the new book index crypt file is written, the random iv and
    # content id are overwritten with the new values, and the old book
    # index crypt file is deleted.
    #
    def write()

      old_crypt_path = FileTree.branch_crypts_filepath( @book_id, @branch_id, @content_id )

      @content_id = Identifier.get_random_identifier( Indices::CONTENT_ID_LENGTH )
      @branch_keys.set( Indices::CONTENT_IDENTIFIER, @content_id )
      write_crypt_path = FileTree.branch_crypts_filepath( @book_id, @branch_id, @content_id )

      iv_base64 = KeyIV.new().for_storage()
      @branch_keys.set( Indices::CONTENT_RANDOM_IV, iv_base64 )
      random_iv = KeyIV.in_binary( iv_base64 )

      Content.lock_it( write_crypt_path, @crypt_key, random_iv, @book.to_json, TextChunk.crypt_header( @book_id ) )
      File.delete( old_crypt_path ) if File.exists? old_crypt_path

    end


    # Return true if this book has NOT been opened at a chapter and verse location.
    # This method uses {TextChunk.not_open_message} to print out a helpful message
    # detailing how to open a chapter and verse.
    #
    # Note that an open chapter need not contain any data. The same goes for an
    # open verse. In these cases the {open_chapter} and {open_verse} methods both
    # return empty data structures.
    #
    # @return [Boolean] true if no chapter and verse for this book is open
    def unopened_chapter_verse?()
      return false if( has_open_chapter_name?() and has_open_verse_name?() )
      TextChunk.not_open_message()
      return true
    end


    # Returns true if this book index has a chapter name specified to be the
    # open chapter. True is returned even if the open chapter data structure
    # is empty.
    # @return [Boolean] true if an open chapter name has been set for this book
    def has_open_chapter_name?()
      return @book.has_key?( Indices::OPENED_CHAPTER_NAME )
    end


    # Returns true if this book index has a verse name specified to be the
    # open verse. True is returned even if the open verse data structure is
    # empty.
    # @return [Boolean] true if an open verse name has been set for this book
    def has_open_verse_name?()
      return @book.has_key?( Indices::OPENED_VERSE_NAME )
    end


    # Returns the name of the chapter that this book has been opened at.
    # If has_open_chapter_name?() returns false this method will throw an exception.
    # @return [String] the name of the chapter that this book is opened at
    def get_open_chapter_name()
      raise RuntimeError, "No chapter has been opened." unless has_open_chapter_name?()
      return @book[ Indices::OPENED_CHAPTER_NAME ]
    end


    # Returns the name of the verse that this book has been opened at.
    # If has_open_verse_name?() returns false this method will throw an exception.
    # @return [String] the name of the verse that this book is opened at
    def get_open_verse_name()
      raise RuntimeError, "No verse has been opened." unless has_open_verse_name?()
      return @book[ Indices::OPENED_VERSE_NAME ]
    end


    # Sets the name of the chapter that this book is to be opened at. This method
    # overwrites the currently open chapter name if there is one.
    # @param chapter_name [String] the name of the chapter to open
    def set_open_chapter_name( chapter_name )
      @book[ Indices::OPENED_CHAPTER_NAME ] = chapter_name
    end


    # Sets the name of the verse that this book is to be opened at. This method
    # overwrites the currently open verse name if there is one.
    # @param verse_name [String] the name of the verse to open
    def set_open_verse_name( verse_name )
      @book[ Indices::OPENED_VERSE_NAME ] = verse_name
    end


    # Returns true if this book index has a chapter name specified to be the
    # open chapter. True is returned even if the open chapter data structure
    # is empty.
    # @return [Boolean] true if an open chapter name has been set for this book
    def has_open_chapter_data?()
      raise RuntimeError, "Unopened chapter prevents data availability check." unless has_open_chapter_name?()
      return @book[ Indices::SAFE_BOOK_CHAPTER_KEYS ].has_key?( get_open_chapter_name() )
    end


    # If chapter keys exist for the open chapter this method returns them. If not,
    # it creates an in-place empty map and returns that.
    #
    # If no chapter in this book has been opened, signalled by has_open_chapter_name?()
    # an exception is thrown.
    # @return [DataStore] the chapter keys for the chapter this book is opened at
    def get_open_chapter_keys()
      raise RuntimeError, "Cannot get chapter keys as no chapter is open." unless has_open_chapter_name?()
      @book[ Indices::SAFE_BOOK_CHAPTER_KEYS ][ get_open_chapter_name() ] = DataStore.new() unless has_open_chapter_data?()
      return @book[ Indices::SAFE_BOOK_CHAPTER_KEYS ][ get_open_chapter_name() ]
    end


    # Returns the data structure corresponding to the book's open chapter.
    # If has_open_chapter_name?() returns false this method will throw an exception.
    # @return [DataStore] the data of the chapter that this book is opened at
    def get_open_chapter_data()
      raise RuntimeError, "Cannot read data as no chapter is open." unless has_open_chapter_name?()
      return @open_chapter_data unless @open_chapter_data.nil?()
      @open_chapter_data = DataStore.new unless has_open_chapter_data?()
      @open_chapter_data = Content.unlock_branch_chapter( get_open_chapter_keys() ) if has_open_chapter_data?()
      return @open_chapter_data
    end


    # Persist the instantiated chapter data structure including all its verses.
    # It doesn't make sense to persist an empty data structure so an exception is
    # raised in this circumstance. Nor can a data structure be persisted if no name
    # is set for the open chapter.
    def set_open_chapter_data()
      raise RuntimeError, "Cannot persist the data with no open chapter name." unless has_open_chapter_name?()
      raise RuntimeError, "Cannot persist a nil or empty data structure." if @open_chapter_data.nil?() or @open_chapter_data.empty?()
      Content.lock_chapter( get_open_chapter_keys(), @open_chapter_data.to_json() )
    end


    # Returns true if this book index has a verse name specified to be the
    # open verse. True is returned even if the open verse data structure
    # is empty.
    # @return [Boolean] true if an open verse name has been set for this book
    def has_open_verse_data?()
      raise RuntimeError, "Cannot look for verse as no open chapter." unless has_open_chapter_name?()
      raise RuntimeError, "Cannot look for verse as no open verse." unless has_open_verse_name?()
      chapter_data = get_open_chapter_data()
      return false if chapter_data.empty?()
      return chapter_data.has_key?( get_open_verse_name() )
    end


    # Returns the data structure corresponding to the book's open verse within
    # the book's open chapter. Both the open chapter and verse names have to be
    # set otherwise an exception will be thrown.
    # @return [DataStore] the data of the verse that this book is opened at
    def get_open_verse_data()
      get_open_chapter_data()[ get_open_verse_name() ] = DataStore.new() unless has_open_verse_data?()
      return get_open_chapter_data()[ get_open_verse_name() ]
    end


    # Write data for the open chapter to the configured safe store. Naturally
    # there must be an open chapter name and the open chapter data cannot be
    # nil or empty otherwise this write will throw an exception.
    def write_open_chapter()
      set_open_chapter_data()
      write()
    end


    # Import and persist the parameter data structure into this book with the
    # parameter chapter name using a deep merge that recursively seeks to preserve
    # all non-duplicate records in both the source and destination structures.
    #
    # <tt>Chapter Alreay Exists</tt>
    #
    # What if a chapter of the given name already exists?
    #
    # In this case we merge the new (incoming) chapter data into the old chapter
    # data. Existing verses not declared in the incoming chapter data continue
    # to live on.
    #
    # Duplicates occur when the same keys posses different values at any level
    # including verse and line (even sub-line levels for assimilated files).The
    # default is to favour incoming values when duplicates are encountered.
    #
    # <tt>Parameter Validation</tt>
    #
    # Neither of the parameters should be nil or empty,
    # nor should the chapter name consist solely of whitespace. Furthermore,
    # the chapter name should respect the constraints imposed by the safe.
    #
    # @param chapter_name [String] the name of the chapter to persist
    # @param chapter_data [DataStore] the chapter data structure to persist
    def import_chapter( chapter_name, chapter_data )

      KeyError.not_new( chapter_name, self )
      raise RuntimeError, "The chapter must not be nil or empty." if( chapter_data.nil?() or chapter_data.empty?() )

      chapter_exists = @book[ Indices::SAFE_BOOK_CHAPTER_KEYS ].has_key?( chapter_name )
      @book[ Indices::SAFE_BOOK_CHAPTER_KEYS ][ chapter_name ] = DataStore.new() unless chapter_exists
      chapter_keys = @book[ Indices::SAFE_BOOK_CHAPTER_KEYS ][ chapter_name ]
      new_chapter = Content.unlock_branch_chapter( chapter_keys ) if chapter_exists
      new_chapter = DataStore.new() unless chapter_exists

      new_chapter.merge_recursively!( chapter_data )
      Content.lock_chapter( chapter_keys, new_chapter.to_json() )

    end


    # Get the number of chapters nestled within this book.
    # @return [Numeric] the number of chapters within this book
    def chapter_count()
      return branch_chapter_keys().length()
    end


    # Is the chapter name in the parameter the book's open chapter? An exception
    # is thrown if the parameter chapter name is nil.
    # @param this_chapter_name [String] the name of the chapter to test
    def is_open_chapter?( this_chapter_name )
      raise RuntimeError, "Cannot test a nil chapter name." if this_chapter_name.nil?()
      return false unless has_open_chapter_name?()
      return this_chapter_name.eql?( get_open_chapter_name() )
    end


    # Return true if the commit identifiers for the master and the branch match
    # meaning that we can commit (commit).
    # @return [Boolean] true if can commit, false otherwise
    def can_commit?()
      return @branch_keys.get( Indices::COMMIT_IDENTIFIER ).eql?( @master_keys.get( Indices::COMMIT_IDENTIFIER ) )
    end



    # Print a notie stating the book followed by and open chapter and
    # verse names only if the book is currently opened at a specific
    # chapter and verse. Right after book creation for example there
    # is no open chapter or verse and this method simply prints out
    # a carriage return.
    def print_book_mark()

      puts ""
      return unless is_opened?()

      bcv_name = "#{book_name()}:#{get_open_chapter_name()}/#{get_open_verse_name()}"
      puts "#{bcv_name} (#{get_open_verse_data().length()})\n"
      puts ""

    end



    # Is the verse name in the parameter the book's open verse? An exception
    # is thrown if the parameter verse name is nil.
    # @param this_verse_name [String] the name of the verse to test
    def is_open_verse?( this_verse_name )
      raise RuntimeError, "Cannot test a nil verse name." if this_verse_name.nil?()
      return false unless has_open_verse_name?()
      return this_verse_name.eql?( get_open_verse_name() )
    end


    # Are both the chapter and verse names in the parameters open? An exception
    # is thrown if any of the parameters are nil.
    # @param chapter_name [String] the name of the chapter to test
    # @param verse_name [String] the name of the verse to test
    def is_open?( chapter_name, verse_name )
      return ( is_open_chapter?( chapter_name ) and is_open_verse?( verse_name ) )
    end


    # Has this book been opened at a chapter and verse location.
    # @return [Boolean] true if it has an open chapter and an open verse
    def is_opened?()
      return has_open_chapter_name?() && has_open_verse_name?()
    end


    # Returns the human readable date/time denoting when the book was
    # first initialized.
    # @return [String] the time that this book was first initialized
    def init_time()
      return @book[ Indices::SAFE_BOOK_INITIALIZE_TIME ]
    end


    # Returns the name of the safe book.
    # @return [String] the name of this book
    def book_name()
      return @book[ Indices::SAFE_BOOK_NAME ]
    end


    # Returns the id number of the safe book.
    # @return [String] the id of this safe book
    def book_id()
      return @book_id
    end


    # Returns the id number of the current safe branch
    # @return [String] the id of this safe branch
    def branch_id()
      return @branch_id
    end


    # Returns the safedb application software version at the time that the
    # safe book was initialized.
    # @return [String] the software version that initialized this book
    def init_version()
      return @book[ Indices::SAFE_BOOK_INIT_VERSION ]
    end


    # Initializes the master book index chapter keys by using the {@crypt_key}
    # along with the random iv and content id (read from the master indices)
    # to decrypt the ciphertext in a master crypt file (found using the book id
    # and content id).
    #
    # Once the book index ciphertext is decrypted access the struct holding
    # the chapter crypt keys, content ids and ivs which is against the
    # {Indices::SAFE_BOOK_CHAPTER_KEYS} index.
    def set_master_chapter_keys()

      random_iv = KeyIV.in_binary( @master_keys.get( Indices::CONTENT_RANDOM_IV ) )
      content_id = @master_keys.get( Indices::CONTENT_IDENTIFIER )
      master_index_filepath = FileTree.master_crypts_filepath( @book_id, content_id )
      master_index = DataStore.from_json( Content.unlock_it( master_index_filepath, @crypt_key, random_iv ) )
      @master_chapter_keys = master_index[ Indices::SAFE_BOOK_CHAPTER_KEYS ]

    end


    # Returns a map of chapter keys that exist within the current branch
    # (line) of this book.
    # An empty map will be returned if no data has been added as yet
    # to the book.
    # @return [DataStore] the data structure holding chapter key data
    def branch_chapter_keys()
      return @book[ Indices::SAFE_BOOK_CHAPTER_KEYS ]
    end


  end


end
