#!/usr/bin/ruby
	
module SafeDb

  # The <b>read use case</b> pulls a file in from either an accessible filesystem
  # or from a remote http, https, git, S3, GoogleDrive and/or ssh source.
  #
  # This use case expects a @file_url parameter. The actions it takes are to
  #
  # - register @in.url to mirror @file_url
  # - register @out.url to mirror @file_url
  # - check the location of @file_url
  # - if no file exists it humbly finishes up
  #
  # If a file does exist at the @in.url this use case
  #
  # - handles HOME directory enabling portability
  # - creates an encryption key and random iv
  # - creates a file (name) id
  # - stores the file byte and human readable size
  # - stores the extension if it has one
  # - stores the last created date
  # - stores the last modified date
  # - stores the (now) in date
  #
  # Once done it displays <b><em>key facts about the file</em></b>.
  class Read < UseCase

# -- ---------------------- --#
# -- ---------------------- --#
# -- [SAFE] Name Changes    --#
# -- ---------------------- --#
# -- Change env.path ~> open.chapter
# -- Change key.path ~> open.verse
# -- Change envelope@xxxx ~> chapter@xxxx
# --
# -- Change filenames to ~~~~~> book.db.breadcrumbs
# -- Change filenames to ~~~~~> chapter.cipher.file
# -- Change filenames to ~~~~~> safe.db.abc123xyzpq
# -- ---------------------- --#
# --    {
# --        "db.create.date": "Sat Aug 11 11:20:16 2018 ( 18223.1120.07.511467675 )",
# --        "db.domain.name": "ab.com",
# --        "db.domain.id": "uhow-ku9l",
# --        "env.path": "aa",
# --        "key.path": "aa",
# --        "envelope@aa": {
# --            "content.xid": "3uzk12dxity",
# --            "content.iv": "XTVe%qIGKVvWw@EKcgSa153nfVPaMVJH",
# --            "content.key": "1u3b2o6KLiAUmt11yYEDThJw1E5Mh4%1iHYOpJQjWiYLthUGgl8IZ5szus8Fz2Jt"
# --        }
# --    }
# -- ---------------------- --#
# -- ---------------------- --#

    attr_writer :file_url

    # The <b>read use case</b> pulls a file in from either an accessible filesystem
    # or from a remote http, https, git, S3, GoogleDrive and/or ssh source.
    def execute

      return unless ops_key_exists?
      master_db = OpenKey::KeyApi.read_master_db()
      return if unopened_envelope?( master_db )

      # -- Get the open chapter identifier (id).
      # -- Decide whether chapter already exists.
      # -- Then get (or instantiate) the chapter's hash data structure
      # --
      chapter_id = ENVELOPE_KEY_PREFIX + master_db[ ENV_PATH ]
      chapter_exists = OpenKey::KeyApi.db_envelope_exists?( master_db[ chapter_id ] )
      chapter_data = OpenKey::KeyDb.from_json( OpenKey::KeyApi.content_unlock( master_db[ chapter_id ] ) ) if chapter_exists
      chapter_data = OpenKey::KeyDb.new() unless chapter_exists

      content_hdr = create_header()

      # -- If no content envelope exists we need to place
      # -- an empty one inside the appdb content database.
      # --
      master_db[ chapter_id ] = {} unless chapter_exists

      # -- We populate (PUT) file instance attributes into
      # -- the mini-dictionary at the [VERSE] location.
      # --
      verse_id = master_db[ KEY_PATH ]
      file_absolute_path = ::File.absolute_path( @file_url )
      chapter_data.create_entry( verse_id, "@in.url", file_absolute_path )
      chapter_data.create_entry( verse_id, "@out.url", file_absolute_path )

      # -- Lock No.1
      # --
      # -- Lock the file content and leave the 3 breadcrumbs
      # -- (content id, content iv and content key) inside
      # -- the file attributes mini dictionary to facilitate
      # -- decrypting and writing out the file again.
      # --
      OpenKey::KeyApi.content_lock( chapter_data[ verse_id ], ::File.read( @file_url ), content_hdr )

      # -- Lock No.2
      # --
      # -- Lock the chapter's data which includes the new or
      # -- updated mini-dictionary that holds the breadcrumbs
      # -- (content id, content iv and content key) that will
      # -- be used to decrypt and write out the file content.
      # --
      # -- Leave another set of breadcrumbs inside the master
      # -- database (content id, content iv and content key)
      # -- to facilitate decrypting the chapter's data.
      # --
      OpenKey::KeyApi.content_lock( master_db[ chapter_id ], chapter_data.to_json, content_hdr )

      # -- Lock No.3
      # --
      # -- Re-lock the master database including the breadcrumbs
      # -- (content id, content iv and content key) that will
      # -- (in the future) decrypt this chapter's data.
      # --
      OpenKey::KeyApi.write_master_db( content_hdr, master_db )


      # -- Communicate that the indicated file has just been
      # -- successfully ingested into the safe.
      # --
      print_file_success master_db[ ENV_PATH ], verse_id, file_absolute_path

    end


    private


    def print_file_success chapter_id, verse_id, file_url

      puts ""
      puts "|-"
      puts "|- Chapter ~> #{chapter_id}"
      puts "|- + Verse ~> #{verse_id}"
      puts "|-"
      puts "|- In File ~> #{file_url}"
      puts "|-"
      puts "|- File cocooned inside your safe."
      puts "|-"
      puts "|-Command Options"
      puts "|-"
      puts "|-    #{COMMANDMENT} put out.dir ~/this/folder"
      puts "|-    #{COMMANDMENT} put out.name new-filename.txt"
      puts "|-    #{COMMANDMENT} write"
      puts "|-"
      puts ""

    end


    # Perform pre-conditional validations in preparation to executing the main flow
    # of events for this use case. This method may throw the below exceptions.
    #
    # @raise [SafeDirNotConfigured] if the safe's url has not been configured
    # @raise [EmailAddrNotConfigured] if the email address has not been configured
    # @raise [StoreUrlNotConfigured] if the crypt store url is not configured
    def pre_validation


    end


  end


end
