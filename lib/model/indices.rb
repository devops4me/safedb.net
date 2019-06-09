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

    # The desired length of a safe book ergonomic identifier.
    SAFE_BOOK_ID_LENGTH = 12

    # The file-system location of the safe database tree
    SAFE_DATABASE_FOLDER = File.join( Dir.home, ".#{SAFE_URL_NAME}" )

    # The fully qualified domain name of the safedb home website
    SAFE_GEM_WEBSITE = "https://www.#{SAFE_URL_NAME}"

    # The safe database github clonable url for the ruby software
    SAFE_GITHUB_URL = "https://github.com/devops4me/#{SAFE_URL_NAME}"

    # The name of the master crypts folder.
    MASTER_CRYPTS_FOLDER_NAME = "safedb-master-crypts"

    # The path to the master crypts folder.
    MASTER_CRYPTS_FOLDER_PATH = File.join( SAFE_DATABASE_FOLDER, MASTER_CRYPTS_FOLDER_NAME )

    # The path to the master crypts .git directory.
    MASTER_CRYPTS_GIT_PATH = File.join( MASTER_CRYPTS_FOLDER_PATH, ".git" )

    # The name of the branch indices folder.
    BRANCH_INDICES_FOLDER_NAME = "safedb-branch-indices"

    # The path to the branch indices folder.
    BRANCH_INDICES_FOLDER_PATH = File.join( SAFE_DATABASE_FOLDER, BRANCH_INDICES_FOLDER_NAME )

    # The name of the branch crypts folder.
    BRANCH_CRYPTS_FOLDER_NAME = "safedb-branch-crypts"

    # The path to the branch crypts folder.
    BRANCH_CRYPTS_FOLDER_PATH = File.join( SAFE_DATABASE_FOLDER, BRANCH_CRYPTS_FOLDER_NAME )

    # The master indices file name
    MASTER_INDICES_FILE_NAME = "safedb-master-indices.ini"

    # The path to the master indices file
    MASTER_INDICES_FILEPATH = File.join( SAFE_DATABASE_FOLDER, MASTER_INDICES_FILE_NAME )

    # The path to the remote storage configuration INI file
    MACHINE_CONFIG_FILEPATH = File.join( SAFE_DATABASE_FOLDER, "safedb-remote-storage.ini" )

    # The machine configuration section (header) name
    MACHINE_CONFIG_SECTION_NAME = "remote.backend"

    # The name of the machine removable drive path location directive
    MACHINE_REMOVABLE_DRIVE_PATH = "removable.drive"

    # The remote database configuration section (header) name
    REMOTE_DATABASE_SECTION_NAME = "remote.backend"

    # Points to the book/chapter/verse coordinates for the remote backend
    REMOTE_BACKEND_PROPERTIES_NAME = "backend.properties"

    # This access token allows us to talk to the Github API
    GITHUB_ACCESS_TOKEN = "@github.access.token"

    # Github repository keyname
    GITHUB_REPOSITORY_KEYNAME = "github.reponame"

    # Github Username Keyname
    GITHUB_USERNAME_KEYNAME = "github.username"

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
    SAFE_VERSION_STRING = "safedb-v#{SafeDb::VERSION}"

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


  end


end
