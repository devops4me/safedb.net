
# Switch On an OpenVPN Client Connection

    safe vpn

## Introduction

This DevOps task is a collaboration to **switch on a VPN connection** with safe as the credentials provider, nmcli on Ubuntu and an OpenVPN account embodied details within an ovpn file.

## Task Preconditions

To switch on a client OpenVPN connection the following must hold true

- a shell safe tokenize, login and open has ocurred
- the opened safe location must have a key vpn.id
- safe write <<runtime.dir>> must eject <<vpn.id>>.ovpn
- the ovpn file must be valid and point to a running accessible openvpn server
- the ubiquitous @password field must hold a credible value
- the VPN connection is assumed to be not just switched off, but deleted (at the start)




# Switch Off an OpenVPN Client Connection

    dot vpn down

## Introduction

This DevOps task is a collaboration to **switch on a VPN connection** with safe as the credentials provider, nmcli on Ubuntu and an OpenVPN account embodied details within an ovpn file.

## Task Preconditions

To switch on a client OpenVPN connection the following must hold true

- a shell safe tokenize, login and open has ocurred
- the opened safe location must have a key vpn.id
- safe write <<runtime.dir>> must eject <<vpn.id>>.ovpn
- the ovpn file must be valid and point to a running accessible openvpn server
- the ubiquitous @password field must hold a credible value
- the VPN connection is assumed to be not just switched off, but deleted (at the start)


# safe vpn up | safe vpn down

    $ safe open vpn production
    $ safe vpn up
    $ ... (do work using vpn)
    $ safe vpn down

## safe vpn | introduction

Once you put VPN credentials into a mini-dictionary (in a safe book chapter and verse), you can bring up a VPN connection and after doing your work through the VPN you can tear it down.

**[The strategy used to bring the OpenVPN connection up and down can be found here.](http://www.devopswiki.co.uk/wiki/middleware/network/openvpn/openvpn)**


### safe vpn | ovpn | requirements

Currently the safe vpn command is only integration tested with the following tech requirements

- an Ubuntu 16.04 and Ubuntu 18.04 operating system
- the nmcli (network manager command line) client which is installed if absent
- an OpenVPN server
- VPN configuration imported via an OpenVPN **`*.ovpn`** file


## safe terraform | credential creation

The first use case is importing the IAM user credentials into safe.

    $ safe login joebloggs.com                  # open the book
    $ safe open iam dev.s3.writer               # open chapter and verse
    $ safe put @access.key ABCD1234EFGH5678     # Put IAM access key in safe
    $ safe put @secret.key xyzabcd1234efgh5678  # Put IAM secret key in safe
    $ safe put region.key eu-west-3             # infrastructure in Paris

    $ safe open iam prod.provisioner            # open chapter and verse
    $ safe put @access.key 4321DCBA8765WXYZ     # Put IAM access key in safe
    $ safe put @secret.key 5678uvwx4321abcd9876 # Put IAM secret key in safe
    $ safe put region.key eu-west-1             # infrastructure in Dublin

    safe logout

Take care to specify these 3 key names **@access.key**, **@secret.key**, **region.key** and note that safe's convention is to sensitively treat the value's of keys beginning with an **@** sign. **safe show** and other readers **mask out (redact)** these sensitive values.


## safe terraform | running terraform

Now and forever you can return to the chapter and verse and enjoy a secure credentials transfer where safe makes the IAM user credentials available to Terraform via environment variables. **Never do the plain text credentials touch the floor (disk).**

### Why no safe terraform init?
**safe only gets involved when credentials are involved**.
**safe** is not trying to wrap command willy nilly. safe's policy is to keep external tool interfaces as **small** as possible. **`terraform init .`** does not involve credentials so safe does not get involved.

    $ cd /path/to/terraform/dir     # go to directory holding your .tf file
    $ safe login joebloggs.com      # login to your chosen book
    $ safe open iam dev.s3.writer   # open chapter and verse holding IAM creds
    $ terraform init .              # the usual terraform init command
    $ safe terraform plan           # credentials are exported then terraform plan is run
    $ safe terraform apply          # credentials are exported then terraform apply is run
    $ safe terraform destroy        # credentials are exported then terraform destroy is run

You can even change directories and run other terraform projects against the opened IAM user. You can also open an IAM user, run commands, open another run commands and then reopen the first and run commands.

As long as you stay within your shell window - your safe login will persist. Once your session is finished you either logout or exit the shell.

### Shortcut Alert

**safe terraform** is a shortcut for **safe terraform apply**

    $ safe terraform apply
    $ safe terraform

## safe terraform | pre-conditions

To enact a successful safe terraform call you will need

- to have created an IAM user
- to open chapter and verse which
- has these 3 keys @access.key @secret.key and region.key (at least)
- terraform installed on the machine or container


## safe terraform | benefits

The safe terraform command is both an ultra secure and extremely convenient way of launching terraform.

Your precious AWS IAM user credentials do not leave the safe and exist within (environment variable) memory only for the duration of the terraform command.

It is safe as you need neither expose your AWS credentials in plain text in **~/.aws/credentials**, nor risk them sliding into version control. It is convenient because switching IAM users and AWS regions is as easy as typing the now ubiquitous safe open command.


## quick tip | view then goto

No need to type out the safe open command everytime. Use it the very first time you create a path to chapter and verse.

    safe open <<chapter>> <<verse>>

Then use safe view and safe goto instead of safe open.

    $ safe view             # list all chapter and verses
    $ safe goto <<index>>   # use the number from safe view to open the location
    $ safe show             # look at your mini dictionary






