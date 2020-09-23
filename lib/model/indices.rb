#!/usr/bin/ruby

module SafeDb

  # Indices are key/value pairs that serve within the safe database index
  # files for denoting, pinpointing, writing and retrieving data values as
  # well as for naming of files folders and other artifacts.
  class Indices

    # The command used to invoke the safe database
    COMMANDER = "safe"

    # The short url name of the safe personal database.
    SAFE_URL_NAME = "safedb.net"

    # The name of the safe application and the safe gem as known by the operating system.
    SAFE_APP_NAME = "safe"

    # The desired length of a safe book ergonomic identifier.
    SAFE_BOOK_ID_LENGTH = 12

    # Environment variable for changing the safe data directory
    SAFE_DATA_DIRECTORY = "SAFE_DATA_DIRECTORY"
    if ( ENV.has_key? SAFE_DATA_DIRECTORY )
      datadir_path = ::File.absolute_path( ENV[ SAFE_DATA_DIRECTORY ] )
      FileUtils.mkdir_p( datadir_path )
      SAFE_DATABASE_FOLDER = datadir_path
    else
      # Unless the data directory is set use this default file-system location
      SAFE_DATABASE_FOLDER = File.join( File.join( Dir.home, ".config" ), SAFE_APP_NAME )
    end

    # The fully qualified domain name of the safedb home website
    SAFE_GEM_WEBSITE = "https://www.#{SAFE_URL_NAME}"

    # The safe database github clonable url for the ruby software
    SAFE_GITHUB_URL = "https://github.com/devops4me/#{SAFE_URL_NAME}"


    ### ##################################### ###
    ### paths to the master and branch assets ###
    ### ##################################### ###

    # The name of the master crypts folder.
    MASTER_BOOKS_FOLDER_NAME = "safe-master-books"

    # The name of the branch crypts folder.
    BRANCH_BOOKS_FOLDER_NAME = "safe-branch-books"

    # The path to the master crypts folder.
    MASTER_CRYPTS_FOLDER_PATH = File.join(SAFE_DATABASE_FOLDER, MASTER_BOOKS_FOLDER_NAME )

    # The path to the branch crypts folder.
    BRANCH_CRYPTS_FOLDER_PATH = File.join(SAFE_DATABASE_FOLDER, BRANCH_BOOKS_FOLDER_NAME )


    # The filename of the index file for a book within master
    BOOK_MASTER_INDEX_FILENAME = "book-master-index.ini"

    # The filename of the index file for a book within a branch
    BOOK_BRANCH_INDEX_FILENAME = "book-branch-index.ini"



    # The simple name of the folder that holds the book chapter crypts
    CHAPTER_CRYPTS_FOLDER_NAME = "chapter-crypts"

    # The string prefix of every chapter filename
    CHAPTER_FILENAME_PREFIX = "safe.chapter"

    # The string prefix of safe book branch folders
    BRANCH_BOOKS_FOLDER_PREFIX = "branch"

    # The path to the master crypts .git directory.
    MASTER_CRYPTS_GIT_PATH = File.join( MASTER_CRYPTS_FOLDER_PATH, ".git" )


    # The master indices file name
    MASTER_INDICES_FILE_NAME = "safedb-master-keys.ini"

    # The path to the master indices file
    MASTER_INDICES_FILEPATH = File.join( MASTER_CRYPTS_FOLDER_PATH, MASTER_INDICES_FILE_NAME )



    # The name of the backup master crypts folder.
    BACKUP_CRYPTS_FOLDER_NAME = "safedb-backup-crypts"

    # The path of the backup master crypts folder.
    BACKUP_CRYPTS_FOLDER_PATH = File.join( SAFE_DATABASE_FOLDER, BACKUP_CRYPTS_FOLDER_NAME )




    # The name of the branch indices folder.
    BRANCH_INDICES_FOLDER_NAME = "safedb-branch-keys"

    # The path to the branch indices folder.
    BRANCH_INDICES_FOLDER_PATH = File.join( SAFE_DATABASE_FOLDER, BRANCH_INDICES_FOLDER_NAME )

    # The path to the remote storage configuration INI file
    MACHINE_CONFIG_FILEPATH = File.join( SAFE_DATABASE_FOLDER, "safedb-remote-storage.ini" )

    # The name of the machine removable drive path location directive
    MACHINE_REMOVABLE_DRIVE_PATH = "removable.drive"




    # The keyname whose value denotes a local folder path to clone to
    GIT_CLONE_BASE_PATH = "git.clone.base.path"




    # The name of the keys section that holds remote mirror properties
    REMOTE_MIRROR_SECTION_NAME = "remote.mirror"

    # The name of the property that points to the book/chapter/verse (page)
    REMOTE_MIRROR_PAGE_NAME = "remote.mirror.page"

    # The ending of the private key filename for remote mirror push access
    REMOTE_MIRROR_PRIVATE_KEY_POSTFIX = "private-key.pem"

    # The key name that holds the remote mirror private key filename
    REMOTE_PRIVATE_KEY_KEYNAME = "private.key.filename"

    # The key name that holds the remote mirror ssh config host value
    REMOTE_MIRROR_SSH_HOST_KEYNAME = "ssh.config.host"

    # The path to the SSH directory
    SSH_DIRECTORY_PATH = File.join( Dir.home(), ".ssh" )

    # The path to the SSH config file
    SSH_CONFIG_FILE_PATH = File.join( SSH_DIRECTORY_PATH, "config" )





    # This access token allows us to talk to the Github API
    GITHUB_ACCESS_TOKEN = "@github.access.token"

    # Github repository keyname
    GIT_REPOSITORY_NAME_KEYNAME = "repository.name"

    # Github Username Keyname
    GIT_REPOSITORY_USER_KEYNAME = "repository.user"

    # Github Host Keyname
    GIT_REPOSITORY_HOST_KEYNAME = "repository.host"




    # Keyname for when the last backend push occured
    REMOTE_LAST_PUSH_ON = "last.push.on"

    # Keyname for the user and hostname that evoked the last push
    REMOTE_LAST_PUSH_BY = "last.push.by"

    # Keyname for the ID of the last push (Usually Git Commit Reference)
    REMOTE_LAST_PUSH_ID = "last.push.id"

    # Private Key Default Key Name
    PRIVATE_KEY_DEFAULT_KEY_NAME = "private.key"

    # Public Key Default Key Name
    PUBLIC_KEY_DEFAULT_KEY_NAME = "public.key"

    # The parameter key name to configure the backend coordinates
    CONFIGURE_BACKEND_KEY_NAME = "backend"

    # The name of the remote database git pull url key
    REMOTE_DATABASE_GIT_PULL_URL = "git.pull.url"

    # The name of the remote database git push url key
    REMOTE_DATABASE_GIT_PUSH_URL = "git.push.url"

    # The desired length of a content identifier
    CONTENT_ID_LENGTH  = 14

    # Content identifiers act to name chapter and/or index database files.
    CONTENT_IDENTIFIER = "content.id"

    # The AES symmetric encryption initialization vector
    CONTENT_RANDOM_IV  = "content.iv"

    # The commit identifiers of the master and branch are compared to ascertain eligibility for commits
    COMMIT_IDENTIFIER = "commit.identifier"

    # The bootup id is set on machine boot and lasts until the reboot or shutdown.
    BOOTUP_IDENTIFIER = "bootup.identifier"

    # The key ciphertext that sits against the trio of either master, branch or chapter
    CRYPT_CIPHER_TEXT = "crypt.cipher"

    # This is the global section header of the branch book index file
    BRANCH_DATA = "branch.data"

    # The time of the first book login within this shell
    BRANCH_INITIAL_LOGIN_TIME = "branch.initial.login.time"

    # The most recent time that any book of this branch was accessed
    BRANCH_LAST_ACCESSED_TIME = "branch.last.accessed.time"

    # The ID of the book being currently used by this branch
    CURRENT_BRANCH_BOOK_ID = "current.branch.book.id"

    # The time this book was first logged into during this branch
    BOOK_BRANCH_LOGIN_TIME = "book.branch.login.time"

    # The time this book was last accessed during this branch
    BOOK_LAST_ACCESSED_TIME = "book.last.accessed.time"

    # The start of the content block laid out in a crypt file
    CONTENT_BLOCK_START_STRING = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789ab\n"

    # The end of the content block laid out in a crypt file
    CONTENT_BLOCK_END_STRING   = "ba9876543210fedcba9876543210fedcba9876543210fedcba9876543210\n"

    # The delimeter used to separate headers from ciphertext in a crypt file
    CONTENT_BLOCK_DELIMITER    = "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

    # The name of the safe tty token environment variable
    TOKEN_VARIABLE_NAME = "SAFE_TTY_TOKEN"

    # The expected length of the tty token environment variable
    TOKEN_VARIABLE_SIZE = 152

    # Character (randomly) repeated to mask credentials
    # Asterices, hyphens, plus and equal signs are common alternatives.
    SECRET_MASK_STRING = "*" * rand( 18 .. 30 )

    # The birthday (initialization time) of this safe book.
    SAFE_BOOK_INITIALIZE_TIME = "book.init.time"

    # The name of this safe book.
    SAFE_BOOK_NAME = "book.name"

    # The application version that oversaw this book's initialization.
    SAFE_BOOK_INIT_VERSION = "book.init.version"

    # The application version that oversaw this book's initialization.
    SAFE_BOOK_CURRENT_VERSION = "book.current.version"

    # The handle to the chapter keys inside the book index.
    SAFE_BOOK_CHAPTER_KEYS = "book.chapter.keys"

    # The opened chapter id/name in the current book
    OPENED_CHAPTER_NAME = "book.open.chapter"

    # The opened verse id/name in the current book
    OPENED_VERSE_NAME = "book.open.verse"

    # The application version that oversaw this book's initialization.
    SAFE_PRE_VERSION_STRING = "safedb-v"

    # Handle to the key name of the ingested file in the submap verse
    INGESTED_FILE_LINE_NAME_KEY = "safedb.file::"

    # Handle to the file base64 content within the submap verse
    INGESTED_FILE_CONTENT64_KEY = "file.content"

    # Handle to the simple name of the ingested file in the submap verse
    INGESTED_FILE_BASE_NAME_KEY = "file.name"

    # The permission setting (chmod) key name
    FILE_CHMOD_PERMISSIONS_KEY = "file.access"

    # The keypair name prefix for private keys.
    PRIVATE_KEY_PREFIX = "private.key"

    # The keypair name prefix for public keys.
    PUBLIC_KEY_PREFIX = "public.key"

    # Elliptic Curve SSL Key Type
    ELLIPTIC_CURVE_KEY_TYPE = "secp384r1"


    ### ##################################### ###
    ### Strings printed to the user interface ###
    ### ##################################### ###

    NOTHING_TO_OBLITERATE = "There is nothing to obliterate."


  end


end
