safe [![Build Status](https://secure.travis-ci.org/TwP/inifile.png)](http://travis-ci.org/TwP/inifile)
==========


## safe push | safe pull

Working with <tt>remote (off-site) storage</tt> and <tt>sync-ing safe books</tt> between **different computers** is done using <tt>safe push</tt> and <tt>safe pull</tt>. Even with a single laptop you need a backup and restore process and this push pull is in-built and ready to go.

The process employs

- a <tt>git repository</tt> to push and pull crypt material to and from
- a usb key, mobile phone and/or email to stash a small file containing salts

Attackers would need to bring together the crypt material, the salt file and your password, in order to access the safe's credentials.

### Command to Acquire Repository State Key

Note = you only need 10 base64 chars to hold the 40 character hex hash.

```
git rev-parse `git log -1 --format=%h HEAD` # acquire the full commit hash hex string
git log -1 --format=%h HEAD                 # pick up the 1st 7 commit hash characters
```

## safe's delivery pipeline

Visit this Rakefile for an example of how to build, test, version and release.

https://github.com/tslocke/hobo/blob/master/Rakefile


safe has an agile and automated delivery pipeline that assures quality, continuity and usability in the major Linux environments including Ubuntu, RHEL, CoreOS, Amazon Linux and Suse Linux.

The pipeline process is triggered when new software arrives in the safedb github repository. When this happens

- Jenkins picks up the latest software
- Rake and Minitest are used to build and unit test the software
- Docker is used to system test safedb in the key Linux environments
- versioning is applied using the date/time and Git's commit hashes
- if tests pass the safedb gem is deployed to RubyGems.org
- website documentation is built and posted to [safedb.net](https://www.safedb.net)

### Command to Acquire Repository State Key

Note = you only need 10 base64 chars to hold the 40 character hex hash.

```
git rev-parse `git log -1 --format=%h HEAD` # acquire the full commit hash hex string
git log -1 --format=%h HEAD                 # pick up the 1st 7 commit hash characters
```

safe database introduction
-----------
**A safe database contains books that you login to.** A book contains **`chapters`** and chapters contain **`verses`**. Each verse has a number of lines which are just key/value pairs.

## Joe Bloggs Social Media Accounts

Joe Bloggs wants to safely store his social media account credentials. His creates a book called **`joe.bloggs`**, a chapter called **`social`** and verses called **facebook**, **twitter**, **instagram** and **snapchat**. These verses will hold key value pairs like username, @password and signin.url (aka lines).

```
safe init joe.bloggs /path/to/dir # create a book called joe.bloggs
safe login joe.bloggs             # login to the book
```

## create facebook credentials

The joe.bloggs book has been created. Now create the **social chapter** and **facebook verse**.

```
safe open social facebook         # open chapter social and verse facebook
safe put username joeybloggs9     # create a username (key/value) line
safe put @password s3cr3t         # create a password (key/value) line
safe put signin.url https://xxx   # create a signin url (key/value) line
```

## create twitter credentials

Now that facebook is done - Joe **creates another verse called twitter** under the social chapter.

```
safe open social twitter        # open chapter social and verse twitter
safe put username joebloggs4    # create a username (key/value) line
safe put @password secret12     # create a password (key/value) line
safe put signin.url https://yyy # create a signin url (key/value) line
```

**`safe open`** creates a new chapter verse or goes to one if it exists. Commands like **`safe put`**, **`safe show`** and **`safe delete`** all work on the currently opened chapter and verse.


## keep it safe

You use **`safe`** to put and retrieve credentials into an uncrackable encrypted "safe" on your filesystem or USB key.

<pre>
You interact with safe on the command line, or through DevOps scripts and pipelines. safe will soon **integrate** with storage solutions like S3, Git, SSH, Docker, Redis, the AWS key manager (KMS), Docker, Google Drive, Kubernetes Secrets, Git Secrets, OAuth2, KeePass, LastPass and the Ansible / HashiCorp vaults.
</pre>

safe is **simple**, intuitive and highly secure. <b><em>It never accesses the cloud</em></b>. The crypt files it writes are precious to you but <b><em>worthless</em></b> to everyone else.

safe | Install and Configure
-----------

## install safe on ubuntu 18.04

    $ sudo apt-get install ruby-full     # for OpenSSL we need full ruby
    $ sudo gem install safedb            # install the safe ruby gem
    $ export SAFE_TTY_TOKEN=`safe token` # setup a shell session variable
    $ safe init joe@abc ~/safedb.creds   # initialize a safe book in folder
    $ safe login joe@abc                 # login with the created password

You initialize then login to a **domain** like **joe@abc**. In the init command we specify where the encrypted material will be stored. Best use a USB key or phone to use your secrets on any drive or computer.

You only need to run init once on a computer for each domain - after that you simply login.

More information will be provided on installing and using safe via a gem install, Ubuntu's apt-get, yum, a docker container, a development install, a unit test install and a software development kit (SDK) install.

## Create Alias for Export Safe Terminal Token

It is tiresome To type <tt>export SAFE_TTY_TOKEN=`safe token`</tt> every time you use the safe. A solution is to create a smaller alias command like <tt>safetty</tt> which will run when we open up a shell.

```bash
echo "alias safetty='export SAFE_TTY_TOKEN=\`safe token\`'" >> ~/.bash_aliases
```

Note the **escaped back-ticks** surrounding <tt>safe token</tt>. It is easy to mistake them for apostrophes.

    $ cat ~/.bash_aliases      # Check the alias has been added to ~/.bash_aliases
    $ source ~/.bash_aliases   # Use source to avoid grabbing a new shell this time

## safe book login command

Now that we have created the <tt>safetty</tt> alias we can login with one line like this.

```bash
safetty; safe login joe@abc
```

Advanced users should avoid adding the export command to <tt>~/.bash_profile</tt>.


## Remove Token | Environment Variable

When the shell closes the shell token will disappear which is good. You can clear it immediately with these commands.

    $ unset SAFE_TTY_TOKEN        # Delete the shell session token
    $ env | grep SAFE_TTY_TOKEN   # Check SAFE_TTY_TOKEN is deleted
    $ env -i bash                 # Delete every env var created by shell


## Chapter and Verse | Its a Book

Visualize your safe **as a book** (like the Bible or the Oxford English Dictionary).

You **open the book at a chapter and verse** then read, write and update a **key/value dictionary**.

- **joe.credentials** is the **book** we login to.
- **email.accounts** is the **chapter** we open
- **joe@gmail.com** is the **verse** we open

Now we can **put** and **read** key/value entries at the chapter and verse we opened.

- <tt>**safe open email.accounts joe@gmail.com**</tt>
- <tt>**safe put username joe**</tt>
- <tt>**safe input password**</tt>
- <tt>**safe put question "Mothers Maiden Name"**</tt>
- <tt>**safe put answer "Rumpelstiltskin"**</tt>
- <tt>**safe tell**</tt>

**What happened?** Look in the configured folder and you'll see some breadcrumbs and your first envelope. What happened was

- the "emal.accounts" envelope is created for joe@gmail.com
- the username and a memorable question are put in
- **safe input password** securely collects the password
- **safe tell** outputs all the data at the opened path

Let's put data for the next email account into the same "email.acocunts" envelope.

- <tt>**safe open email.accounts joe@yahoo.com**</tt>
- <tt>**safe put username joey**</tt>
- <tt>**safe input secret**</tt>
- <tt>**safe tell**</tt>


## emacs passwords | safe login

Emacs tries to detect a password prompt by examining the prompt text. These will match.

- Password:
- Enter new password:

Use **`Alt-x send-invisible`** or **`M-x send-invisible`** if emacs gets it wrong.

In emas passwords entered in the special minibuffer

- are not displayed
- nor are they entered into any history list

There are ways to help Emacs recognize password prompts using regular expressions and lisp lists but this complexity is rarely warranted.

## Keeping Files Secret

**Whole files can be secured in the safe - not just a sequence of characters.**

### A single file

**This is legacy functionality and will soon be refactored using the multi-file embedded map approach.**

You can pull in (and spit out) a file into the dictionary at the opened chapter and verse using **`safe read`** and **`safe write`**

    $ safetty                         # alias command puts token in an environment variable
    $ safe login <<book>>             # login to a book
    $ safe open <<chapter>> <<verse>> # go to the dictionary at the opened chapter/verse
    $ safe show                       # look at the key/value pairs in the dictionary
    $ safe read ~/creds/my-key.pem    # an encrypted file is added to the safe directory
    $ safe write                      # the file is decrypted and faithfully returned

With read/write only one file can be added to a dictionary. If you **safe read** the second time the safe file is effectively overwritten and unretrievable. Note that **safe write** creates a backup if the file exists at the filepath before overwriting it.

But can we put more than one file into a dictionary?

### Putting Many Files into a Dictionary

**These commands may be refactored into read and write.**
Suppose you have 4 openvpn (ovpn) files and you want them encrypted in just one dictionary. You can do it with **safe inter** and **safe exhume**

    $ safe inter production.vpn ~/tmp-vpn-files/prod.ovpn
    $ safe inter development.vpn ~/tmp-vpn-files/dev.ovpn
    $ safe inter canary.vpn ~/tmp-vpn-files/canary.ovpn
    $ safe inter staging.vpn ~/tmp-vpn-files/stage.ovpn
    $ safe show

Against the @production.vpn key exists a sub-dictionary holding key-value pairs like in.url, out.url, permissions, is_zip, use_sudo, date_created, date_modified and most importantly **content**.

The actual file content is converted into a url safe base64 format (resulting in a sequence of characters) and then put into the dictionary with keys named production.vpn, canary.vpn and so on.

    $ safe exhume

This powerful command **excavates all files** thus reconstituting them into their configured plaintext destinations.

    $ safe exhume production.vpn                 # dig out just the one file
    $ safe exhume 'production.vpn,canary.vpn'    # dig out every file in the list
    $ safe exhume production.vpn ~/new/live.ovpn # dig out file to specified path


In keeping with the safe tradition of zero parameter commands whenever and wherever possible the **safe inter** command will now reread all the files again because safe knows where they should be.

    $ safe inter

### Passing Files in through Standard In

**@Yet to be implemented. Above inter/exhume should be read/write and the below should be the real inter/exhume**
File content can be presented at standard in (stdin) and ejected to (stdout) in keeping with unix command tradition.

    $ cat ~/.ssh/repo-private-key.pem | safe inter repo.key
    $ safe exhume repo.key > /media/usb/repository-key.pem

Internally and therefore private - inter converts the multiline text into urlsafe base 64 on the way (std)in and exhume does the opposite on the way (std)out.

## Scripts can Read Safe's Credentials

Within a DevOps script, you can read from a safe and write to it without the credentials touching the ground (disk) and/or sides.

DevOps engineers often comment that this is the safe's most attractive feature. All you have to do is to tell safe that it is being called from within a script. This an example of connecting to a database maybe to create some space.

    $ safetty
    $ safe login joe@bloggs.com
    $ safe open mysql production

    $ python db-create-space.py

You've logged into a safe book and opened a chapter and verse. Then you call a script - **look no parameters!**

(Improve by using actual python commands).

Now within the script could be lines like this.

    db_url  = %x[safe print db.url --script]
    db_usr  = %x[safe print db.usr --script]
    db_pass = %x[safe print db.pass --script]

    db_conn = Connection.new( db_url, db_usr, db_pass )

Notice the credentials have not touched the disk. The decrypted form was only used in memory to connect.

The switch **--script** tells safe that it is being called from within a script. Safe won't give out credentials if the script in turn calls another script and that calls safe - it only obliges when you have run the command yourself.

This gives you peace of mind that sub-processes two or more levels deep will not be able to access your credentials.

You can also limit the credentials in a book. Scripts can only access credentials in books that you have logged into. Credentials in other books within your safe are out of scope.


## Scripts can Write Credentials into your Safe

Many DevOps scripts source credentials that then need to be stored. Scripts can use Safe's configurable random generators to produce passwords, public/private keypairs and AES keys. Or the credentials are sourced externally and the scripts then place them into the safe.


## safe | The Commands

    $ safe login <<book>>              # login to one of the books in the safe
    $ safe use   <<book>>              # switch to this or that book (if logged in)
    $ safe open <<chapter>> <<verse>>  # open email accounts chapter at this verse (specific account)
    $ safe view                        # contents page of chapters and verses in this book
    $ safe goto <<N>>                  # shortcut for open command (pick number from the viewed list

    $ safe put <<key>> <<value>>       # put in a non-sensitive key-value pair
    $ safe put @<<key>> <<value>>       # put in a non-sensitive key-value pair

    $ safe show                        # show the key/value dictionary at chapter and verse


## Chapter and Verse | Types

What types can safe store. Remember the
- book
- chapter
- verse

You login to a book and then "open" it up at a chapter and verse.

At that point you get a dictionary with string keys. The value types can be

- strings
- integers
- booleans
- lists
- dictionaries
- another book, chapter and verse
- files (plain, binary, zip)

## Concepts Yet to be Documented

We need to fix the login bug which we now workaround by init(ing) every time.
On top of that we must document the behaviour for

- list management (create read add remove eject) - remove is given a value while eject is given an index
- crud operations on books, chapters, verses and key/value entries
- password changing
- hardening configuration using Hexadecimal characters

## How to configure safe's behaviour

We can configure safe's behaviour

- globally for all books on a given workstation
- locally for activities pertaining to the current book


## Exporting Credentials in Different Formats

Once credentials are in safe they can be exported in different formats.
Also you can start a shell, login, open a chapter and verse and then give safe the command to run.

It can then export out selected (key/value) dictionaries at the opened chapter and verse as

- **environment variables**
- **Kubernetes Secrets formatted files**
- **AWS IAM user environment variables or files**
- **RubyGem credentials (consumable by rake)**
- **rclone credentials for accessing GoogleDrive, Rackspace**
- **openvpn (ovpn) files (with keys/certs) for VPN tunnels**
- **ubuntu network manager configurations fir VPN and wireless**
- **certificates RubyGem credentials (consumable by rake)**
- **git credentials for pushing (or cloning) a git repo**

In effect, safe can start VPNs, wireless connections, launch Firefox with certificates installed, run Ansible and Terraform suppling vital credentials - all this **without the credentials ever touching the ground (filesystem)**.

## Generating Credentials

The most powerful known technique for generating a random sequence of characters on Linux involves the <tt>urandom</tt> command.

### urandom command example

```
head /dev/urandom | tr -dc A-Za-z0-9 | head -c 18 ; echo ''
head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20 ; echo ''
```

## Generating Credential Types

The following can be generated from a single command

- password strings configurable by length, set of printable characters and encoding
- private / public key pairs with bit length configurable (up to 8192 bits) - also format configurable
- AWS SSH keypairs
- certifcates including signed (root) certificates

## Allowing Credentials Access

Once the above are locked inside your safe - you

### Did you know?

Did you know that
- plaintext credentials are written by git config credential.helper store
- plaintext credentials are written (out of home directory) by ubuntu network manager
- plaintext credentials live under an AWS config directory.


## Configure Length of Generated Password

```
head /dev/urandom | tr -dc A-Za-z0-9 | head -c 18 ; echo ''
head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20 ; echo ''
```

Visit the below - has perfect parameters for configuring the output of a generating credential.

https://www.terraform.io/docs/providers/random/r/string.html

Maybe find the Go software or Ruby alternatives.

The following arguments are supported:

- length - (Required) The length of the string desired
- upper - (Optional) (default true) Include uppercase alphabet characters in random string.
- min_upper - (Optional) (default 0) Minimum number of uppercase alphabet characters in random string.
- lower - (Optional) (default true) Include lowercase alphabet characters in random string.
- min_lower - (Optional) (default 0) Minimum number of lowercase alphabet characters in random string.
- number - (Optional) (default true) Include numeric characters in random string.
- min_numeric - (Optional) (default 0) Minimum number of numeric characters in random string.
- special - (Optional) (default true) Include special characters in random string. These are '!@#$%&*()-_=+[]{}<>:?'
- min_special - (Optional) (default 0) Minimum number of special characters in random string.
- override_special - (Optional) Supply your own list of special characters to use for string generation. This overrides characters list in the special argument. The special argument must still be set to true for any overwritten characters to be used in generation.
- keepers - (Optional) Arbitrary map of values that, when changed, will trigger a new id to be generated. See the main provider documentation for more information.


     $ safe password length <<weight>>

The length of randomly generated passwords (secret strings) can be weighted from 1 to 32. The generated
password length can still vary but is guaranteed to be one of 7 possible lengths as shown below.

        | ---------------------- | -------------------- |
        |                        | Expected Char Count  |
        | ---------------------- | -------------------- |
        | Password Length Weight | Min  | Median | Max  |
        | ---------------------- | -------------------- |
        |         1              |  8   |   11   |  14  |
        |         2              |  9   |   12   |  15  |
        |         3              |  10  |   13   |  16  |
        |         4              |  11  |   14   |  17  |
        |         5              |  12  |   15   |  18  |
        |         6              |  13  |   16   |  19  |
        |         7              |  14  |   17   |  20  |
        |         8              |  15  |   18   |  21  |
        |         9              |  16  |   19   |  22  |
        |         10             |  17  |   20   |  23  |
        |         11             |  18  |   21   |  24  |
        |         12 (default)   |  19  |   22   |  25  |
        |         13             |  20  |   23   |  26  |
        |         14             |  21  |   24   |  27  |
        |         15             |  22  |   25   |  28  |
        |         16             |  23  |   26   |  29  |
        |         17             |  24  |   27   |  30  |
        |         18             |  25  |   28   |  31  |
        |         19             |  26  |   29   |  32  |
        |         20             |  27  |   30   |  33  |
        |         21             |  28  |   31   |  34  |
        |         22             |  29  |   32   |  35  |
        |         23             |  30  |   33   |  36  |
        |         24             |  31  |   34   |  37  |
        |         25             |  32  |   35   |  38  |
        |         26             |  33  |   36   |  39  |
        |         27             |  34  |   37   |  40  |
        |         28             |  35  |   38   |  41  |
        |         29             |  36  |   39   |  42  |
        |         30             |  37  |   40   |  43  |
        |         31             |  38  |   41   |  44  |
        |         32             |  39  |   42   |  45  |
        | ---------------------- | -------------------- |

The lowest 1 setting will produce a 8, 9, 10, 11, 12, 13 or 14 character password.

The default password hovers in the low to mid twenties whilst the hardest 32 setting will generate a
length 42 password string (give or take 3 characters on either side).

No extra benefit is derived from generating passwords with lengths in excess of 42 characters.

Don't forget that the above has **nothing** to do with the password you choose to protect your safe safe.
This only applies to (securely) randomly generated character sequences used to create passwords for external
applications and systems.

### Configure Makeup of Password | Printable Characters

Run the below command and note the large character set from which secrets and passwords are generated.
The larger the character set the **exponentially** more difficult to brute force crack a password. That said, many websites and services impose restrictions on the characters set, usually in an attempt to prevent sql injection and cross-site-scripting attacks.

<tt>safedb</tt> allows you to specify the character set at the book, chapter, verse, line and also at the command line level.

```
head /dev/urandom | tr -dc A-Za-z0-9?@=$~%/+^.,][\{\}\<\>\&\(\)_\- | head -c 258 ; echo
```

For easy configuration, just specify --flaky, --weak, --solid, --strong and --herculean.


Some systems reject certain characters. Lloyds Bank for example will only accept alpha-numerics.

In these cases we need to configure the set of characters that sources the actual sequence of password characters.

Again you can configure 1 to 32 which guarantees that the generated password sequence will be locked down to
(possibly) include a character and all those that come before it.

There are 62 alpha-numerics which is the starting point and smallest source pool of usable choosable characters for a printable character sequence.

        - ---------------------- | -------------------- - --------- -
        | Password Makeup Weight |  #   | Char Name     | Character |
        | ---------------------- | -----| ------------- | --------- |
        |         1              |  62  | alpha-nums    | A-Za-z0-9 |
        |         2              |  63  | underscore    |   _       |
        |         3              |  64  | period        |   .       |
        |         4              |  65  | hyphen        |   -       |
        |         5              |  66  | at symbol     |   @       |
        |         6              |  67  | squiggle      |   ~       |
        |         7              |  68  | hyphen        |   -       |
        |         8              |  69  | plus sign     |   +       |
        |         9              |  70  | percent       |   %       |
        |         10             |  71  | equals        |   =       |
        |         11             |  72  | SPACE         |           |
        |         12             |  73  | fwd slash     |   /       |
        |         13             |  74  | hat symbol    |   ^       |
        |         14             |  75  | soft open     |   (       |
        |         15             |  76  | soft close    |   )       |
        |         16             |  77  | square open   |   [       |
        |         17             |  78  | square close  |   ]       |
        |         18             |  79  | curly open    |   {       |
        |         19             |  80  | curly close   |   }       |
        |         20             |  81  | angle open    |   <       |
        |         21             |  82  | angle close   |   >       |
        |         22             |  83  | pipe symbol   |   |       |
        |         23             |  84  | hash symbol   |   #       |
        |         24             |  85  | question mark |   ?       |
        |         25             |  86  | colon         |   :       |
        |         26             |  87  | semi-colon    |   ;       |
        |         27             |  88  | comma         |   ,       |
        |         28             |  89  | asterix       |   *       |
        |         29             |  90  | ampersand     |   &       |
        |         30             |  91  | exclamation   |   !       |
        |         31             |  92  | dollar sign   |   $       |
        |         32             |  93  | back tick     |   `       |
        | ---------------------- | -----| ------------- | --------- |

Use the full set of **93 printable characters** when protecting high value assets like databases.

### Binary Data

Some more advanced cryptography leaning services can handle binary streams (usually encoded) - safe can produce these at the drop of a hat.

### Kubernetes Secrets

safe can transfer a verse (or even the whole chapter) into a Kubernetes Secrets compatible format.

Kubernetes Secrets (through the kubectl interface) require that hexadecimal (base64) encoding be applied to secrets coming in through the letterbox.

safe can output dictionary (key/value pair) configurations in a format consumable by Kubernetes secrets.

### Encoding Character Sequences





### safe | All Done!

Cracking safe is infeasible for anyone other than the rightful owner. Only OpenSSL implemented tried and tested cryptographic algorithms are used. Both PBKDF2 and BCrypt are used for expensive key derivation. The content is encrypted with AES (Advanced Encryption Standard) and 48 byte random keys are employed along with initialization vectors.

Even with all this crypt technology it is **important** that you

- choose a robust password of between 10 and 32 characters
- align the number of salt derivation iteratios to your machine's resources
- backup the domain folders in case you lose your USB drive or phone

Your ability to access your own secrets (even after disaster scenarios) is as important as preventing the secrets being accessed.

safe | moving computer
-----------

We travel between laptops, desktops, virtual machines and even docker containers. Always run init the first time you use a domain on a different computer.

    $ gem install safe
    $ export SAFE_TTY_TOKEN=`safe token`        # setup a shell session variable
    $ safe init joe@abc /home/joe/credentials   # initialize a secrets domain
    $ safe login joe@abc                        # login to the new domain

Run all four commands the first time. Then simply run the second and fourth commands whenever you open a new shell to interact with safe.

## the no-go no-clouds mantra

safe is designed to operate in highly secure locked down environments in which external access is not just constrained - **it is non-existent**.

safe does not contact nor talk to anything external. It never asks (nor needs to know) the credentials for accessing your stores - this means it compliments your storage security be it S3, Google Drive, Redis, Git and even email/pop3 solutions.

## the encrypted at rest mantra

The ability to read data from drives (after the fact and) after deletion means **nothing unencrypted** should be put on any drive (including usb keys).


safe configuration
------------------------

Aside from your private keys, safe keeps a small amount of configuration within the .safe folder off your home directory. A typically safe.ini file within that folder looks like

    [joebloggs@example.com]
    type    = user
    id      = joe
    keydir  = /media/joe/usb_drive
    domains = [ lecturers@harvard ]
    default = true
    printx  = asdfasdfas65as87d76fa97ds6f57as6d5f87a
    printy  = asdfasdfas65as87d76fbbbasdfas0asd09080
    printz  = adsfasdflkajhsdfasdf87987987asd9f87987

    [lecturers@harvard]
    type    = domain
    store   = git
    url     = https://www.eco-platform.co.uk/crypt/lecturers.git



Backend Storage Options
-----------------------

The planned list of backend storage systems (each onlined with a plugin), is

- Git (including GitHub, GitLab, BitBucket, OpenGit and private Git installations).
- S3 Buckets from the Amazon Web Services (AWS) cloud.
- SSH, SCP, SFTP connected file-systems
- network storage including Samba, NFS, VMWare vSAN and
- GoogleDrive (only Windows has suitable synchronized support).

Access management is configured EXTERNAL to safe. SafeDb simply piggybacks the network transport if authorization is granted.


## safe | Summary

You can use safe alone or you can use it to share secrets with colleagues, friends and family, even machines.

safe is simple and holistically secure. *Simple* means less mistakes, less confusion and more peer reviews from internet security experts.

Every domain is tied to backend storage which is accessible by you and others in your domain. You can use Git, S3, a networked filesystem or shared drive, a SSH accessible filesystem and soon, free storage from <tt>safe.io</tt>


## How to Use SafeDb as an SDK | Require it from another Ruby program

You can require safe (as an SDK) and interact with it directly from any other Ruby program without wrappers.

    $ gem install safe
    $ irb
    $ > require "safe"
    $ > SafeDb::Interprete.version()

The above should return the **installed version** of SafeDb.

If you get a **LoadError (cannot load such file -- safe)** then try the below.

    $ irb
    $ > $LOAD_PATH

[
   "/usr/share/rubygems-integration/all/gems/did_you_mean-1.2.0/lib",
   "/usr/local/lib/site_ruby/2.5.0",
   "/usr/local/lib/x86_64-linux-gnu/site_ruby",
   "/usr/local/lib/site_ruby",
   "/usr/lib/ruby/vendor_ruby/2.5.0",
   "/usr/lib/x86_64-linux-gnu/ruby/vendor_ruby/2.5.0",
   "/usr/lib/ruby/vendor_ruby",
   "/usr/lib/ruby/2.5.0",
   "/usr/lib/x86_64-linux-gnu/ruby/2.5.0"
]




## SAFE PROPOSED FUNCTIONALITY DOCUMENTATION


Before we can move to siloed safe workspaces and RELEASE the software into the public domain we must refactor file handling and implement vital methodologies for evolving the software.

## File Storage Methodology

- delete the concepts of content.id, content.iv and content.key in the context of files.
- add one more key to file verse @file.content and store the urlsafe base64 contents of the file there

@@@@@@@@@@@@ change
@@@@@@@@@@@@ change ==> maybe better to create a sub dictionary (map) for the file so will be
@@@@@@@@@@@@ change ==> key value pairs. Keys could be permissions - 755 | @content - BASE64 file representation | read.url - http://shareprices/mcdonalds.yaml | write.url $HOME/shares/mcds.yaml | type - binary
@@@@@@@@@@@@ change

This move means that if we wish to export and import we do not need to fiddle with chapter files vs file files.

---

## Advanced | Sub Lists and Sub Dictionaries

### Introduce Concept of Lists, Sets and Dictionaries within the Verse Mini Dictionary

This concept will come with more commands - like so

safe add favfoods rice
safe insert favfoods |5| potato ## Note first index is 0 -> Also -2 is 2nd last | default is -1 (append at the end)
safe remove favfoods chicken
safe pop favfoods |3|
safe place cityfacts {}
safe place cityfacts { "london" => "6,200,000", "beijing" => "20,500,000", "new york" => "9,300,000" }
safe get cityfacts beijing
safe remove cityfacts "new york"

Also you can now print in many formats including --hex, --json, --base64, --xml, --ini, --yaml


---

## Import Export Methodology

Now build export to simply spit out everything into plain text chapter files (within safe workspace - export section).
Then the json chapter files are tarred and compressed.
Build import to uncompress then unzip then use the JSON to re-create the database

---

## Upgrade methodology

This move opens the door to safe's beautifully simple upgrade methodology. To upgrade safe to a major or minor version you

- use the outgoing version to export all books
- then we upgrade safe
- then we use the new safe software to import and you are done.

---

Now we have cleared the path for a SIMPLE Backup and Restore method.

## Backup Restore Methodology

The backup/restore MUST BE VERSION AGNOSTIC (in as far as is human and machinely possible.
Employ the export first giving us first zip file.
Then add a backup meta-data file with details like who when why which tag which version and most IMPORTANTLY the random IV and SALT for the key that locks the exported content file.

The backup method retars up compresse both the metadata and the locked file. The new filename is like this.

    safe.backup.<<book-name-code>>.<<time-stamp-millis>>.<<version>>.tar.gz

It adds it to the local safe backup workspace. It can only be done when logged in.
     
    safe restore /path/to/backup/file.tar.gz

A restore will override the current in-place repository (after creating a backup of it) and user given option to rollback the restore.

This method (theoretially) allows a version 3.428.24952 to restore an export of version 1.823.03497

---

## Safe's Concurrency Methodology

A safe repository (book) can be changed by one session but read concurrently by multiple sessions.

Directory Links are NOT PORTABLE to use to point to the active workspace especially if we the safe root folder is on a USB key.
A GOOD engough concurrency technique is a lock file in the BOOK's root folder that is named `safe.concurrency.lockfile.<<book.id>>`

The contents of the file will hold the relative directory name (session ID based) that has the lock and the session ID that had it before that (if not first).

The <machine.id>.<bootup.id> is used to when the first read/write login session occurs. Subsequent logins for a read/write session will then have 2 choices in this shell.

- safe login ali.baba --steal    # take over the primary read/write session
- safe login ali.baba --branch   # leave primary session but open one that will not change the price of sugar
- safe login ali.baba --branch=master
- safe login ali.baba --branch=experimental
- safe login ali.baba -b experimental

safe login --steal

A third choice arises if we visit the shell holding the directory pointer and logout.

### safe logout command

Logout NEVER TOUCHES the lock file (it could have moved on multiple times so only login can act on it).

However logout DELETES the cipher.file intra-sessionary ciphertext that can be unlocked by session key to retrieve the content key. This action renders it impossible to read or write any data from logged in book.

A subsequent login can again re-instate this privilege.

## safe login command

At the very beginning a repository can come into being through either

- an init
- or a clone (from git,s3,ssh,local filesystem, http)

The first repo holds the live link.

Subsequent logins must perform two checks

- IS MY DIRECTORY (session) noted as the latest in the lock file (possible if you've logged out of the same shell)
- (if other directory) - Does the intra-sessionary key within that directory's cipher file have a value

The popup asking the user to STEAL or go READONLY is triggered if the answers above are NO then YES.

### Safe steal | HowTo

If intra key has no value then stealing is not necessary so the existence of the --steal flag does not change the price of sugar.

The Stealing flow of events is to

 - copy the directory into a new one for this session named `<<book.id>>.<<timestamp>>.<<session.key>>`
 - validate the directory for data consistency (nice to have functionality)
 - collect the password and if invalid stop now
 - grab the lock file and write it to point it to our directory (we are it)
 - create our own intra-sessionary key and write it in within our folder

### Safe branch | HowTo

Starting a BRANCH allows you to read and write to a copied branched repository but this branch does not change the price of sugar.

In the future MERGE functionality may be implemented so that the database branch can be merged back into the master line.

May a safe overthrow command can be crudely done which rudely overthrows the main (government) line and installs this dictatorish branch as the leader - possibly trashing any changes that the master line may have since the branch occured.


## safe gc (garbage collector) | safe workspace prune

The prune command can delete workspaces if
- they are not the master branch AND
- they have not been changed in this bootup (or a logout has been issued againt them).

## safe WORO policy

chapter files can only be written once but can be read often.
This policy may make merging and diffs between branches easier in the future.







### Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/safe. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

License
-------

MIT License
Copyright (c) 2006 - 2014

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
