#!/usr/bin/ruby

module SafeDb

  # Indices are key/value pairs that serve within the safe database index
  # files for denoting, pinpointing, writing and retrieving data values as
  # well as for naming of files folders and other artifacts.
  class Indices


    # The short url name of the safe personal database.
    SAFEDB_URL_NAME = "safedb.net"

    # The name ofthe master crypts folder.
    MASTER_CRYPTS_FOLDER_NAME = "safedb-master-crypts"

    # The name ofthe session indices folder.
    SESSION_INDICES_FOLDER_NAME = "safedb-session-indices"

    # The name ofthe session crypts folder.
    SESSION_CRYPTS_FOLDER_NAME = "safedb-session-crypts"

    # The file-system location of the safe database tree
    SAFE_DATABASE_FOLDER   = File.join( Dir.home, ".#{SAFEDB_URL_NAME}" )

    # The desired length of a content identifier
    CONTENT_ID_LENGTH  = 14

    # Content identifiers act to name chapter and/or index database files.
    CONTENT_IDENTIFIER = "content.id"

    # The AES symmetric encryption initialization vector
    CONTENT_RANDOM_IV  = "content.iv"

    # The start of the content block laid out in a crypt file
    CONTENT_BLOCK_START_STRING = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789ab\n"

    # The end of the content block laid out in a crypt file
    CONTENT_BLOCK_END_STRING   = "ba9876543210fedcba9876543210fedcba9876543210fedcba9876543210\n"

    # The delimeter used to separate headers from ciphertext in a crypt file
    CONTENT_BLOCK_DELIMITER    = "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

    # The master commit id is synonymous with a git commit hash
    MASTER_COMMIT_ID  = "master.commit.id"

    # The session commit id is compared with the master to determine whether a commit (save) is possible
    SESSION_COMMIT_ID = "session.commit.id"

    # The inter session crypt is locked with the human key for retrieval at the next login
    INTER_SESSION_KEY_CRYPT = "inter.session.key.crypt"

    # The intra session crypt is locked with the session key for retrieval at the next command
    INTRA_SESSION_KEY_CRYPT = "intra.session.key.crypt"

    # The chapter content is locked with the key that is marshalled from the value here
    CHAPTER_KEY_CRYPT = "chapter.key.crypt"

    # This is the global section header of the session book index file
    SESSION_DATA = "session.data"

    # The time of the first book login within this shell session
    SESSION_FIRST_LOG_IN_POINT = "session.first.log.in.point"

    # The most recent time that any book of this session was accessed
    SESSION_LAST_ACCESSED_TIME = "session.last.accessed.time"

    # The ID of the book being currently used by this session
    CURRENT_SESSION_BOOK_ID = "current.session.book.id"

    # The time this book was first logged into during this session
    BOOK_SESSION_LOGIN_TIME = "book.session.login.time"

    # The time this book was last accessed during this session
    BOOK_LAST_ACCESSED_TIME = "book.last.accessed.time"

    # The name of the safe tty token environment variable
    TOKEN_VARIABLE_NAME = "SAFE_TTY_TOKEN"

    # The expected length of the tty token environment variable
    TOKEN_VARIABLE_SIZE = 152


  end


end
