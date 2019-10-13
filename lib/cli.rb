require "thor"
require "fileutils"
require "strscan"

require "utils/logs/logger"
require "controller/requirer"

# Include the logger mixins so that every class can enjoy "import free"
# logging through pointers to the (extended) log behaviour.
include LogImpl


# This standard out sync command flushes text destined for STDOUT immediately,
# without waiting either for a full cache or completion.
$stdout.sync = true


# Recursively require all gems that are either in or under the directory
# that this code is executing from. Only use this tool if your library is
# relatively small but highly interconnected. In these instances it raises
# productivity and reduces pesky "not found" exceptions.
SafeDb::Require.gems( __FILE__ )


# This command line processor extends the Thor gem CLI tools in order to
#
# - read the posted commands, options and switches
# - maps the incoming string data to objects
# - assert that the mandatory options exist
# - assert the type of each parameter
# - ensure that the parameter values are in range
# - delegate processing to the registered handlers

class CLI < Thor


  log.info(x) { "request to interact with a safe book has been received." }


  # With this class option every (and especially the log) use case has
  # the option of modifying its behaviour based on the presence and state
  # of the --debug switch.
  class_option :debug, :type => :boolean


  # Any use case can modify its behaviour if this <tt>--to-dir</tt> class
  # option is present. For example the file write (eject) use case can place
  # files in the directory specified by this switch.
  #
  # <tt>class_option :to_dir, :default => Dir.pwd, :aliases => '-t'</tt>
  #
  # @todo - adding "default" prevents many many conditionals downstream
  # <tt>eject.rb</tt> has FOUR (4) conditionals (already) dedicated to this
  # single field (at the time of writing).
  class_option :to_dir, :aliases => '-t'


  # Printout the version of this safedb.net command line interface.
  desc "version", "prints the safedb.net command line interface version"

  # If <tt>safe --version</tt> is issued this line accepts it and converts
  # it so that the version method is called.
  map %w[-v --version] => :version

  # Printout the version of this safedb.net command line interface.
  # The version should be extracted whether the user types in
  #
  # - either <tt>safe --version</tt>
  # - or <tt>safe version</tt>
  def version
    log.info(x) { "print the version of this safedb.net personal database." }

    puts ""
    puts "safedb gem version => v#{SafeDb::VERSION}"
    puts "time and date now  => #{SafeDb::TimeStamp.human_readable()}"
    puts "safedb @github.com => https://github.com/devops4me/safedb.net"
    puts "safe @rubygems.org => https://rubygems.org/gems/safedb"
    puts ""

  end



  # Description of the book initialize call.
  desc "init <book_name> <storage_dir>", "initialize a new safe credentials book"

  # Use <tt>password</tt> if confident that either the command history is
  # inaccessible or the call originates from non-interactive software.
  option :password, :aliases => '-p'

  # Initialize a safe credentials book with this name and collect the human sourced
  # pasword to be put through key derivation functions.
  #
  # @param book_name [String] the name of the credentials book to be created
  def init( book_name )
    log.info(x) { "initialize a new safe credentials book called [#{book_name}]." }
    init_uc = SafeDb::Init.new
    init_uc.password = options[ :password ] if options[ :password ]
    init_uc.book_name = book_name
    init_uc.flow()
  end



  # Description of the login use case command line call.
  desc "login <book_name>", "login to the book before interacting with it"

  # Use <tt>password</tt> if confident that either the command history is
  # inaccessible or the call originates from non-interactive software.
  option :password, :aliases => '-p'

  # The <tt>--clip</tt> option says the password is to be read from the
  # clipboard. Usually one needs to just highlight the text without
  # actually copying it with the mouse or Ctrl-c
  method_option :clip, :type => :boolean, :aliases => "-c"

  # Login in order to securely interact with your safe credentials.
  # @param book_name [String] the name of the credentials book to login to
  def login( book_name = nil )
    log.info(x) { "login attempt to the safe book called [#{book_name}]." }
    login_uc = SafeDb::Login.new
    login_uc.book_name = book_name unless book_name.nil?
    login_uc.password = options[ :password ] if options[ :password ]
    login_uc.clip = true if options[ :clip ]
    login_uc.clip = false unless options[ :clip ]
    login_uc.flow()
  end



  # Description of the tell use case command line call.
  desc "tell", "detail the secret key/value pairs that start with the @ symbol"

  # Detail the secret key/value pairs that start with the @ symbol.
  def tell
    log.info(x) { "tell the secret key/value pairs that begin with the @ symbol." }
    SafeDb::Tell.new().flow()
  end



  # Description of the print use case command line call.
  desc "print <key_name>", "print the key value at the opened chapter and verse"

  # Print the value of the specified key belonging to a dictionary at
  # the opened chapter and verse of the currently logged in book.
  #
  # @param key_name [String] the key whose value is to be printed
  def print key_name
    log.info(x) { "print the key value at the opened chapter and verse." }
    print_uc = SafeDb::Print.new
    print_uc.key_name = key_name
    print_uc.flow()
  end



  # Description of the copy use case command line call.
  desc "copy <line>", "copy a line value (at the current chapter/verse) into the clipboard."

  # Copy into the clipboard the value held by the named line at the
  # current book's open chapter and verse.
  #
  # This is more accurate and more secure than echoing the password and
  # then performing a SELECT then COPY and then PASTE.
  # 
  # Use <b>safe clear</b> to wipe (overwrite) the sensitive value in
  # the clipboard.
  #
  # @param line [String] the name of the line whose data will be copied.
  #        If no line is given the default @password is assumed.
  def copy( line = nil )
    log.info(x) { "copy the line value at the current chpater/verse into the clipboard." }
    copy_uc = SafeDb::Copy.new
    copy_uc.line = line
    copy_uc.flow()
  end



  # Description of the paste use case command line call.
  desc "paste <line>", "paste a value into the line key which defaults to @password if not provided."

  # Paste the current clipboard or selection text into the specified line
  # at the current book's open chapter and verse.
  #
  # Sensitive values now neither need to be put on the commnad line (safe put)
  # or inputted perhaps with a typo when using (safe input).
  # 
  # Use <b>safe wipe</b> to wipe (overwrite) any sensitive values that has
  # been placed on the clipboard.
  #
  # @param line [String] the name of the line that the copied data will be
  #        placed alongside. The line either may or may not exist.
  def paste( line = nil )
    log.info(x) { "paste the line value within the clipboard into the current chpater/verse." }
    paste_uc = SafeDb::Paste.new
    paste_uc.line = line
    paste_uc.flow()
  end



  # Description of the safe token use case.
  desc "token", "generate and print out an encrypted (shell bound) shell token"

  # The<b>token</b> use cases prints out an encrypted shell token tied
  # to the workstation and shell environment.
  def token
    log.info(x) { "generate and print out an encrypted (shell bound) shell token" }
    SafeDb::Token.new.flow()
  end



  # Description of the safe wipe use case.
  desc "wipe", "Wipe both clipboards of any sensitive data that may exist there."

  # The<b>wipe</b> use case clears out any sensitive information from the clipboard.
  def wipe
    log.info(x) { "wipe out any sensitive information from the clipboard." }
    SafeDb::Wipe.new.flow()
  end



  # Description of the open use case command.
  desc "open <chapter> <verse>", "open a chapter and verse to read from or write to"

  # Open up a conduit (path) to the place where we can issue read, create, update,
  # and destroy commands.
  #
  # The allowed characters that makeup chapter and verse aside from alphanumerics are
  #
  # - dollar signs
  # - percent signs
  # - ampersands
  # - hyphens
  # - underscores
  # - plus signs
  # - equal signs
  # - @ signs
  # - period characters and
  # - question marks
  #
  # Notably whitespace including spaces and tabs are not allowed.
  #
  # @param chapter [String]
  #    the chapter of the logged in book to open
  #
  # @param verse [String]
  #    the verse of the logged in book and specified chapter to open
  def open chapter, verse
    log.info(x) { "open a chapter and verse to read from or write to." }
    open_uc = SafeDb::Open.new
    open_uc.chapter = chapter
    open_uc.verse = verse
    open_uc.flow()
  end



  # Description of the diff use case command from the point of view
  # of either a refresh from master to branch, or a commit from branch
  # to master, depending on what is permissible given the state.
  desc "diff", "master and branch diff that indicates whether a commit or refresh can happen."

  # The <b>diff use case</b> spells out the key differences between the safe book
  # on the master line the one on the current working branch.
  #
  # By default when conflicts occur, priority is given to the current working branch.
  # No parameters are required to perform a diff.
  def diff
    log.info(x) { "prophesy list of either refresh or commit actions." }
    SafeDb::Diff.new().flow()
  end



  # Description of the commit use case command.
  desc "commit", "commit (save) the branch changes by putting them into master."

  # The <b>commit use case</b> commits any changes made to the safe book into
  # master. This is straightforward if the master's state has not been forwarded
  # by a ckeckin from another (shell) branch.
  def commit
    log.info(x) { "commit (save) any changes made to this branch into the master." }
    SafeDb::Commit.new.flow()
  end



  # Description of the refresh use case command.
  desc "refresh", "refresh (update) the working branch with changes from the master."

  # The <b>refresh use case</b> commits any changes made to the safe book into
  # master. This is straightforward if the master's state has not been forwarded
  # by a ckeckin from another (shell) branch.
  def refresh
    log.info(x) { "refresh (update) the working branch with changes from the master." }
    SafeDb::Refresh.new.flow()
  end



  # Description of the export use case command.
  desc "export", "exports the book or chapter or the mini dictionary at verse."

  # Export one, some or all chapters, verses and lines within the logged in book.
  # The --print flag demands that the exported text goes to stdout otherwise it
  # will be placed in an aptly named file in  the present working directory.
  def export
    log.info(x) { "export book chapter content or dictionary at verse in JSON format." }
    SafeDb::Export.new.flow()
  end



  # Description of the import use case command.
  desc "import", "imports the contents of the parameter json file into this book."

  # The <b>import use case</b> takes a filepath parameter in order to pull in
  # a <em>json</em> formatted data structure.
  # @param import_filepath [String] the path to the JSON file that we will import
  def import import_filepath
    log.info(x) { "importing into current book from file #{import_filepath}." }
    import_uc = SafeDb::Import.new
    import_uc.import_filepath = import_filepath
    import_uc.flow()    
  end



  # Description of the put secret command.
  desc "put <key> <value>", "put key/value pair into dictionary at open chapter and verse"

  # Put a secret with an id like login/username and a value like joebloggs into the
  # context (eg work/laptop) that was opened with the open command.
  #
  # @param credential_id [String] the id of the secret to put into the opened context
  # @param credential_value [String] the value of the secret to put into the opened context
  def put credential_id, credential_value
    log.info(x) { "put key/value pair into dictionary at open chapter and verse." }
    put_uc = SafeDb::Put.new
    put_uc.credential_id = credential_id
    put_uc.credential_value = credential_value
    put_uc.flow()
  end



  # Description of the remote command.
  desc "remote --provision", "Create (provision) remote storage for the safe database (backend) crypt files."

  # The <tt>--provision</tt> option conveys that we want to carve out
  # some remote storage so that our database can be accessed by multiple
  # machines in different corners of the globe.
  method_option :provision, :type => :boolean, :aliases => "-p"

  # Creates remote storage for the safe database crypt files.
  def remote
    log.info(x) { "performing a remote storage use case. The provision flag is set to #{options[ :provision ]}." }
    remote_uc = SafeDb::RemoteGithubToken.new()
    remote_uc.provision = true if options[ :provision ]
    remote_uc.provision = false unless options[ :provision ]
    remote_uc.flow()
  end



  # Description of the safe git command.
  desc "git --clone", "Clone the remote repository whose properties are in the current chapter and verse."

    # If the --clone switch is included this class will expect to be at a verse
    # that contains either a github token, username, reponame combination or a
    # publicly publicly clonable url, or ssh url with the private keys and SSH host
    # configuration already setup.

    # If the --push switch is included this class will expect to be at a verse
    # that has a path to a git url within it. If this is missing the present working
    # directory is assumed to be the git repository in question.
    #
    # If the verse contains a branch name which is not the current branch then
    # we raise a query to the user instead of pushing to the wrong place. This is
    # a good double (sanity) check.


    # If the --push switch is included this class will expect to be at a verse
    # that has a path to a git url within it. If this is missing the present working
    # directory is assumed to be the git repository in question.

    # If the --no-ssl-verify switch is passed into this class it will urge git not
    # to worry when a site does not have a (presently) trusted SSL certificate.

    # If the --to switch has a value which is a path to a local (possibly non-existing)
    # folder to clone to - this will override the verse line git.clone.path

#####  method_option :provision, :type => :boolean, :aliases => "-p"


  def git
    log.info(x) { "performing a git repository interaction." }
####    git_uc = SafeDb::Git.new()
#####    remote_uc.provision = true if options[ :provision ]
#####    remote_uc.provision = false unless options[ :provision ]
####    git_uc.flow()
    SafeDb::Git.new().flow()
  end



  # Description of the safe database push command.
  desc "push", "push commited safe crypts to the remote backend repository."

  # This simple command does not require the user to be logged into a specific
  # book. The only pre-condition is that safe remote --provision has been successfully
  # run thus placing the required remote origin urls.
  def push
    log.info(x) { "request to push safe crypts to the remote backend." }
    SafeDb::Push.new().flow()
  end



  # Description of the set configuration directives command.
  desc "set <directive_name> <directive_value>", "set book-scoped configuration directive"

  # The <b>set <em>use case</em></b> is the generic tool for setting book scoped
  # configuration directives. These directives can only be read, written, updated
  # or removed during a logged in branch.
  #
  # @param directive_name [String] the name of the book-scoped configuration directive
  # @param directive_value [String] the value of the book-scoped configuration directive
  def set directive_name, directive_value
    log.info(x) { "set the configuration directive value for #{directive_name}" }
    set_uc = SafeDb::Set.new
    set_uc.directive_name = directive_name
    set_uc.directive_value = directive_value
    set_uc.flow()
  end



  # Description of the generate command.
  desc "generate <line>", "generate a string password that conforms to configured properties"

  # The <b>generate use case</b> generates a random string credential that abides by
  # the laws set out by configured and/or default parameter properties. These properties
  # include the character superset to which all credential characters belong, the median
  # length of the credential and the (give or take) span denoting the shortest and
  # longest possible credentials.
  #
  # @param line [String] name of line the credential is stored against. Defaults to @password
  def generate( line = "@password" )
    log.info(x) { "generate a string credential and store it against line [#{line}]." }
    generate_uc = SafeDb::Generate.new()
    generate_uc.line = line
    generate_uc.flow()
  end



  # Description of the remove command.
  desc "remove <line_id>", "remove a line (key/value pair), or a verse, chapter and even a book"

  # The <b>remove use case</b> can remove a single line (key/value pair), or
  # a verse, chapter and even a book
  #
  # @param line_id [String] the ID of the entity to remove (line, verse, chapter or book)
  def remove line_id
    log.info(x) { "remove a safe entity with a key id [#{line_id}]." }
    remove_uc = SafeDb::Remove.new()
    remove_uc.line_id = line_id
    remove_uc.flow()
  end



  # Description of the rename command.
  desc "rename <now_name> <new_name>", "rename an existing chapter, verse or line"

  # The <b>rename use case</b> can rename an existing chapter, verse or line.
  # @param now_name [String] the existing name of the chapter, verse or line
  # @param new_name [String] the new name the chapter, verse or line goes by
  def rename now_name, new_name
    log.info(x) { "rename the existing chapter, verse or line from [ #{now_name} ] to [ #{new_name} ]." }
    rename_uc = SafeDb::Rename.new()
    rename_uc.now_name = now_name
    rename_uc.new_name = new_name
    rename_uc.flow()
  end


  # Description of the safe keys command.
  desc "keys <name>", "create a public/private keypair against the given name."

  # The default action of the <b>keys use case</b> is to create a private and
  # public keypair and store them within the open chapter and verse.
  # @param keypair_name [String] optional name of the keypair (for example gitlab)
  def keys( keypair_name = nil )
    log.info(x) { "Generate an elliptic curve private and public cryptographic keys." }
    log.info(x) { "The keypair name [ #{keypair_name} ] was given." } if keypair_name
    keys_uc = SafeDb::Keys.new
    keys_uc.keypair_name = keypair_name if keypair_name
    keys_uc.flow()
  end



  # Description of the read command.
  desc "read <file_url>", "read file into the open chapter and verse for safe keeping."

  # The <b>read use case</b> pulls a file in from either an accessible filesystem.
  #
  # @param file_key [String] keyname representing the file that is being read in
  # @param file_url [String] url of file to ingest and assimilate into the safe
  def read file_key, file_url
    log.info(x) { "read file into key #{file_key} from url #{file_url}" }
    read_uc = SafeDb::Read.new
    read_uc.file_key = file_key
    read_uc.file_url = file_url
    read_uc.flow()
  end



  # Description of the write command.
  desc "write <file_key>", "write out file to current folder or use --to_dir=/path/to/dir."

  # The <b>write use case</b> writes out a file that was previously ingested
  # and coccooned inside the safe.
  #
  # @param file_key [String] the key name of the file to write out onto the filesystem
  def write( file_key )
    log.info(x) { "write out the file against key #{file_key}" }
    log.info(x) { "output folder optionally set to #{options[:to_dir]}" } if options[:to_dir]
    write_uc = SafeDb::Write.new
    write_uc.file_key = file_key
    write_uc.to_dir = options[:to_dir] if options[:to_dir]
    write_uc.flow()
  end



  # Description of the show secret command.
  desc "show", "show dictionary at the opened chapter and verse"

  # Show the secrets at the opened path. These secrets
  # are simply written out to the shell console.
  def show
    log.info(x) { "show dictionary at the opened chapter and verse." }
    SafeDb::Show.new.flow()
  end



  # Description of the view command.
  desc "view", "print list of chapter and verse combos to console"

  # Display a bird's eye view of the domain's database including
  # its envelopes, their keys and imported objects such as files.
  def view
    log.info(x) { "print list of chapter and verse combos to console." }
    view_uc = SafeDb::View.new
    view_uc.flow()
  end



  # Description of the goto use case command.
  desc "goto <index>", "shortcut that opens chapter and verse at specified index"

  # Goto is a shortcut (or alias even) for the open command that takes an integer
  # index that effectively specifies which <envelope> and <key> to open.
  #
  # @param index [Number]
  #    the integer index chosen from the list procured by the view command.
  def goto index
    log.info(x) { "opens the chapter and verse at index [#{index}]." }
    goto_uc = SafeDb::Goto.new
    goto_uc.index = index
    goto_uc.flow()

  end



  # Description of the terraform integration use case command.
  desc "terraform <command>", "runs terraform after exporting IAM credentials at opened location"

  # This terraform use case exports the AWS IAM user access key, secret key and region key
  # into (very safe) environment variables and then runs terraform plan, apply or destroy.
  #
  # This is both ultra secure and extremely convenient because the credentials do not leave
  # the safe and exist within (environment variable) memory only for the duration of the
  # terraform command.
  #
  # It is safe because you do not need to expose your AWS credentials in plain text.
  # It is convenient because switching IAM users and AWS regions is as easy as typing the now
  # ubiquitous safe open command.
  #
  #     safe open <<chapter>> <<verse>>
  #
  # @param command [String]
  #    the terraform command to run which is currently limited to plan, apply and destroy.
  #    This parameter is optional and if nothing is given then "apply" is assumed.
  def terraform( command = nil )
    log.info(x) { "will export IAM credentials then invoke $ terraform #{command}" }
    terraform_uc = SafeDb::Terraform.new
    terraform_uc.command = command if command
    terraform_uc.debug = true if options[ :debug ]
    terraform_uc.debug = false unless options[ :debug ]
    terraform_uc.flow()
  end



  # Description of the jenkins integration use case command.
  desc "jenkins <<command>> <<what>> <<where>>", "sends credentials to the Jenkins 2 CI service."

  # This Jenkins use case injects for example the AWS IAM user access key, secret key and region key
  # into a running Jenkins CI (Continuous Integration) service at the specified (url) location.
  #
  #     safe jenkins post aws http://localhost:8080
  #
  # @param command [String]
  #
  #    the action to be taken which is currently limited to be [post].
  #
  # @param service [String]
  #
  #    Which service do the credentials being posted originate from? The crrent list includes
  #
  #      - aws      ( the 3 IAM user credentials )
  #      - docker   ( the username / password of docker repository )
  #      - git      ( the username/password of Git repository )
  #      - rubygems ( the username / password of RubyGems package manager account )
  #
  # @param url [String]
  #
  #    the full url of the jenkins service for example http://localhost:8080
  #    which includes the scheme (http|https) the hostname or ip address and
  #    the port jenkins is listening on (if not the default 80 or 443).
  #
  def jenkins( command, service, url )

    log.info(x) { "request to #{command} #{service} credentials to Jenkins at #{url}" }
    jenkins_uc = SafeDb::Jenkins.new

    jenkins_uc.command = command if command
    jenkins_uc.service = service if service
    jenkins_uc.url     = url     if url

    jenkins_uc.flow()

  end



  # Description of the docker repository integration use case command.
  desc "docker <<command>>", "logs into or out of the dockerhub repository."

  # This docker use case ....
  #
  #     safe docker login
  #     safe docker logout
  #
  # @param command [String]
  #    the action to be taken which is currently limited to either
  #    login or logout
  def docker( command = "login" )

    log.info(x) { "request to #{command} into or out of a docker repository." }
    docker_uc = SafeDb::Docker.new
    docker_uc.command = command
    docker_uc.flow()

  end



  # Description of the vpn use case command.
  desc "vpn <command>", "runs vpn command typically safe vpn up or safe vpn down"

  # This VPN use case connects to the VPN whose specifics are recorded within the vpn.ini
  # factfile living in the same directory as the vpn.rb controlling class.
  #
  # @param command [String]
  #    the vpn command to run which is currently limited to up or down
  #    This parameter is optional and if nothing is given then "up" is assumed.
  def vpn( command = nil )
    log.info(x) { "VPN connection command #{command} has been issued." }
    vpn_uc = SafeDb::Vpn.new
    vpn_uc.command = command if command
    vpn_uc.flow()
  end



  # Description of the identifier command.
  desc "id", "prints out the current timestamp identifiers"

  # Put out the multiple formats of the current timestamp.
  def id
    log.info(x) { "prints out the current timestamp identifiers." }
    id_uc = SafeDb::Id.new
    id_uc.flow()
  end



end
