require "thor"
require "fileutils"

require "session/time.stamp"
require "logging/gem.logging"
require "session/require.gem"


# Include the logger mixins so that every class can enjoy "import free"
# logging through pointers to the (extended) log behaviour.
include OpenLogger


# This standard out sync command flushes text destined for STDOUT immediately,
# without waiting either for a full cache or script completion.
$stdout.sync = true


# Recursively require all gems that are either in or under the directory
# that this code is executing from. Only use this tool if your library is
# relatively small but highly interconnected. In these instances it raises
# productivity and reduces pesky "not found" exceptions.
OpenSession::RecursivelyRequire.now( __FILE__ )


# This command line processor extends the Thor gem CLI tools in order to
#
# - read the posted commands, options and switches
# - maps the incoming string data to objects
# - assert that the mandatory options exist
# - assert the type of each parameter
# - ensure that the parameter values are in range
# - delegate processing to the registered handlers

class Interprete < Thor


  log.info(x) { "request to interact with a safe book has been received." }


  # With this class option every (and especially the log) use case has
  # the option of modifying its behaviour based on the presence and state
  # of the --debug switch.
  class_option :debug, :type => :boolean

  # The script class option is implemented in the parent {SafeDb::UseCase}
  # use case enabling behaviour alteration based on the presence and state of
  # the --script flag.
  class_option :script, :type => :boolean



  # Description of the init configuration call.
  desc "init <book_name> <storage_dir>", "initialize the safe book on this device"

  # If confident that command history cannot be exploited to gain the
  # human password or if the agent running safe is itself a script,
  # the <tt>with</tt> option can be used to convey the password.
  option :with

  # Initialize the credentials manager, collect the human password and
  # manufacture the strong asymmetric public / private keypair.
  #
  # @param domain_name [String] the domain the software operates under
  # @param base_path [String] the path to the base operating directory
  def init( domain_name, base_path = nil )
    log.info(x) { "initialize the safe book on this device." }
    init_uc = SafeDb::Init.new
    init_uc.master_p4ss = options[:with] if options[:with]
    init_uc.domain_name = domain_name
    init_uc.base_path = base_path unless base_path.nil?
    init_uc.flow_of_events
  end



  # Description of the login use case command line call.
  desc "login <book_name>", "login to the book before interacting with it"

  # If confident that command history cannot be exploited to gain the
  # human password or if the agent running safe is itself a script,
  # the <tt>with</tt> option can be used to convey the password.
  option :with

  # Login in order to securely interact with your data.
  # @param domain_name [String] the domain the software operates under
  def login( domain_name = nil )
    log.info(x) { "[usecase] ~> login to the book before interacting with it." }
    login_uc = SafeDb::Login.new
    login_uc.domain_name = domain_name unless domain_name.nil?
    login_uc.master_p4ss = options[:with] if options[:with]
    login_uc.flow_of_events
  end



  # Description of the print use case command line call.
  desc "print <key_name>", "print the key value at the opened chapter and verse"

  # Print the value of the specified key belonging to a dictionary at
  # the opened chapter and verse of the currently logged in book.
  #
  # @param key_name [String] the key whose value is to be printed
  def print key_name
    log.info(x) { "[usecase] ~> print the key value at the opened chapter and verse." }
    print_uc = SafeDb::Print.new
    print_uc.key_name = key_name
    print_uc.from_script = options[:script].nil? ? false : options[:script]
    print_uc.flow_of_events
  end



  # Description of the verse use case command line call.
  desc "verse", "print the verse name at the opened chapter and verse"

  # Print the name of the verse at the opened chapter and verse location.
  def verse
    log.info(x) { "[usecase] ~> print the verse name at the opened chapter and verse." }
    verse_uc = SafeDb::Verse.new
    verse_uc.from_script = options[:script].nil? ? false : options[:script]
    verse_uc.flow_of_events
  end



  # Description of the safe token use case.
  desc "token", "generate and print out an encrypted (shell bound) session token"

  # The<b>token</b> use cases prints out an encrypted session token tied
  # to the workstation and shell environment.
  def token
    log.info(x) { "[usecase] ~> generate and print out an encrypted (shell bound) session token" }
    SafeDb::Token.new.flow_of_events
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
    log.info(x) { "[usecase] ~> open a chapter and verse to read from or write to." }
    open_uc = SafeDb::Open.new
    open_uc.env_path = chapter
    open_uc.key_path = verse
    open_uc.flow_of_events
  end



  # Description of the export use case command.
  desc "export", "exports the book or chapter or the mini dictionary at verse."

  # Export the entire book if no chapter and verse is specified (achieved with a safe close),
  # or the chapter if only the chapter is open (safe shut or safe open <<chapter>>, or the
  # mini-dictionary at the verse if both chapter and verse are open.
  def export
    log.info(x) { "[usecase] ~> export book chapter content or dictionary at verse in JSON format." }
    SafeDb::Export.new.flow_of_events
  end



  # Description of the put secret command.
  desc "put <key> <value>", "put key/value pair into dictionary at open chapter and verse"

  # Put a secret with an id like login/username and a value like joebloggs into the
  # context (eg work/laptop) that was opened with the open command.
  #
  # @param secret_id [String] the id of the secret to put into the opened context
  # @param secret_value [String] the value of the secret to put into the opened context
  def put secret_id, secret_value
    log.info(x) { "[usecase] ~> put key/value pair into dictionary at open chapter and verse." }
    put_uc = SafeDb::Put.new
    put_uc.secret_id = secret_id
    put_uc.secret_value = secret_value
    put_uc.flow_of_events
  end



  # Description of the file command.
  desc "file <file_key> <file_url>", "ingest a file into the safe from the filesystem (or S3, ssh, Google Drive)"

  # The <b>file use case</b> pulls a read in from either an accessible readsystem
  # or from a remote http, https, git, S3, GoogleDrive and/or ssh source.
  #
  # @param file_key [String] keyname representing the file that is being read in
  # @param file_url [String] url of file to ingest and assimilate into the safe
  def file file_key, file_url
    log.info(x) { "[usecase] ~> file read against key [[ #{file_key} ]]" }
    log.info(x) { "[usecase] ~> file read from url [[ #{file_url} ]]" }
    file_uc = SafeDb::FileMe.new
    file_uc.file_key = file_key
    file_uc.file_url = file_url
    file_uc.flow_of_events
  end



  # Description of the eject command.
  desc "eject <file_key>", "write out ingested file at chapter/verse with specified file key"

  # The <b>eject use case</b> writes out a file that was previously ingested
  # and coccooned inside the safe typically with the file command.
  #
  # @param file_key [String] the key that the file was ingested against
  def eject file_key
    log.info(x) { "[usecase] ~> eject file at chapter/verse against specified key." }
    eject_uc = SafeDb::Eject.new
    eject_uc.file_key = file_key
    eject_uc.flow_of_events
  end



  # Description of the delete command.
  desc "delete <entity_id>", "delete a line (key/value pair), or a verse, chapter and even a book"

  # The <b>delete use case</b> can delete a single line (key/value pair), or
  # a verse, chapter and even a book
  #
  # @param entity_id [String] the ID of the entity to delete (line, verse, chapter or book)
  def delete entity_id
    log.info(x) { "[usecase] ~> delete a safe entity with a key id [#{entity_id}]." }
    delete_uc = SafeDb::DeleteMe.new
    delete_uc.entity_id = entity_id
    delete_uc.flow_of_events
  end



  # Description of the read command.
  desc "read <file_url>", "read (reread) file either locally or via http, git or ssh"

  # The <b>read use case</b> pulls a read in from either an accessible readsystem
  # or from a remote http, https, git, S3, GoogleDrive and/or ssh source.
  #
  # This use case expects a @file_url parameter. The actions it takes are to
  #
  # - register @in.url to mirror @file_url
  # - register @out.url to mirror @file_url
  # - check the location of @file_url
  # - if no file exists it humbly finishes up
  #
  # @param file_url [String] url of file to ingest and assimilate into the safe
  def read file_url
    log.info(x) { "[usecase] ~> read (reread) file from optional url [[ #{file_url} ]]" }
    read_uc = SafeDb::Read.new
    read_uc.file_url = file_url
    read_uc.flow_of_events
  end



  # Description of the write command.
  desc "write <file_url>", "write out file at chapter/verse to (optional) file url"

  # The <b>write use case</b> writes out a file that was previously ingested
  # and coccooned inside the safe.
  #
  # @param file_url [String] optional file url marking where to write the file
  def write( file_url = nil )
    log.info(x) { "[usecase] ~> write out file at chapter/verse to (optional) file url." }
    write_uc = SafeDb::Write.new
    write_uc.from_script = options[:script].nil? ? false : options[:script]
    write_uc.file_url = file_url if file_url
    write_uc.flow_of_events
  end



  # Description of the show secret command.
  desc "show", "show dictionary at the opened chapter and verse"

  # Show the secrets at the opened path. These secrets
  # are simply written out to the shell console.
  def show
    log.info(x) { "[usecase] ~> show dictionary at the opened chapter and verse." }
    SafeDb::Show.new.flow_of_events
  end



  # Description of the view command.
  desc "view", "print list of chapter and verse combos to console"

  # Display a bird's eye view of the domain's database including
  # its envelopes, their keys and imported objects such as files.
  def view
    log.info(x) { "[usecase] ~> print list of chapter and verse combos to console." }
    view_uc = SafeDb::View.new
    view_uc.flow_of_events
  end



  # Description of the goto use case command.
  desc "goto <index>", "shortcut that opens chapter and verse at specified index"

  # Goto is a shortcut (or alias even) for the open command that takes an integer
  # index that effectively specifies which <envelope> and <key> to open.
  #
  # @param index [Number]
  #    the integer index chosen from the list procured by the view command.
  def goto index
    log.info(x) { "[usecase] ~> opens the chapter and verse at index [#{index}]." }
    goto_uc = SafeDb::Goto.new
    goto_uc.index = index
    goto_uc.flow_of_events

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
    log.info(x) { "[usecase] ~> will export IAM credentials then invoke $ terraform #{command}" }
    terraform_uc = SafeDb::Terraform.new
    terraform_uc.command = command if command
    terraform_uc.flow_of_events
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

    log.info(x) { "[usecase] ~> request to #{command} #{service} credentials to Jenkins at #{url}" }
    jenkins_uc = SafeDb::Jenkins.new

    jenkins_uc.command = command if command
    jenkins_uc.service = service if service
    jenkins_uc.url     = url     if url

    jenkins_uc.flow_of_events

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

    log.info(x) { "[usecase] ~> request to #{command} into or out of a docker repository." }
    docker_uc = SafeDb::Docker.new
    docker_uc.command = command
    docker_uc.flow_of_events

  end



  # Description of the vpn use case command.
  desc "vpn <command>", "runs vpn command typically safe vpn up or safe vpn down"

  # This VPN use case connects to the VPN whose specifics are recorded within the vpn.ini
  # factfile living in the same directory as the vpn.rb usecase class.
  #
  # @param command [String]
  #    the vpn command to run which is currently limited to up or down
  #    This parameter is optional and if nothing is given then "up" is assumed.
  def vpn( command = nil )
    log.info(x) { "[usecase] ~> VPN connection command #{command} has been issued." }
    vpn_uc = SafeDb::Vpn.new
    vpn_uc.command = command if command
    vpn_uc.flow_of_events
  end



  # Description of the identifier command.
  desc "id", "prints out the current timestamp identifiers"

  # Put out the multiple formats of the current timestamp.
  def id
    log.info(x) { "[usecase] ~> prints out the current timestamp identifiers." }
    id_uc = SafeDb::Id.new
    id_uc.flow_of_events
  end



end
