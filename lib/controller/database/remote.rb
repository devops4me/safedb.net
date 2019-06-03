#!/usr/bin/ruby
	
module SafeDb

  # We want to provision (create) the safe's remote (github) backend.
  #
  # A number of setup tasks are executed when you ask that the backend repository be created.
  #
  # - a repository is created in github
  # - the git fetch (https) and git push (ssh) urls are fabricated
  # - the fetch url is written to the **`safedb-master-indices.ini`**
  # - the push url is written to the configured chapter/verse location
  # - a ssh public/private keypair (using EC25519) is created
  # - the private and public keys are placed within the chapter/verse
  # - the public (deploy) key is registered with the github repository
  #
  class Remote < Controller

    attr_writer :create

    # We want to provision (create) the safe's remote (github) backend.
    # A number of setup tasks are executed when you ask that the backend repository be created.
    def execute()

      return unless @create

      repository_name = "safedb-crypts-#{TimeStamp.yyjjj_hhmm_sst()}"
      backend_properties = Master.new().get_backend_coordinates()

=begin

Setting up passwordless git interactions (cloning, pulling, pushing) is the same as setting up passwordless ssh login.

To interact with Git without passwords you need to

- setup a public private SSH keypair
- install and lock down the private key
- create a SSH IdentityFile called config in `$HOME/.ssh/config`
- install the public key into BitBucket, GitLab, GitHub or a SSH accessible repo

### Setup Passwordless SSH

Passwordless SSH is a prerequisite to passwordless git interaction.

### The SSH Identity File

The Identity File is telling the SSH subsystem that when you see this particular hostname (IP Address) - you submit this private key because that host will for sure have the corresponding public key in its authorized keys cache.

When using Github, Gitlab or BitBucket - you go to a screen and enter in the public key portion.

```
Host bitbucket.server
StrictHostKeyChecking no
HostName bitbucket.org
User joebloggs276
IdentityFile /home/joebloggs/.ssh/bitbucket-repo-private-key.pem
```

### The Passwordless SSH Setup Commands

Our local user `joebloggs` has an account with `bitbucket.org` with username `joebloggs276` and has submitted the public key to it. He has created a private key at `/home/joebloggs/.ssh/bitbucket-repo-private-key.pem` (locked with a 400) and an identity file at `/home/joebloggs/.ssh/config`.

``` bash
ssh-keygen -t rsa                                              # enter /home/joebloggs/.ssh/bitbucket-repo-private-key.pem
chmod 400 /home/joebloggs/.ssh/bitbucket-repo-private-key.pem  # restrict to user read-only permissions
GIT_HOST_IP=bitbucket.org                                      # set the hostname as bitbucket.org
ssh-keyscan $GIT_HOST_IP >> /home/joebloggs/.ssh/known_hosts   # prevents a authenticity of host cant be established prompt
ssh -i /home/joebloggs/.ssh/bitbucket-repo-private-key.pem -vT "joebloggs276@$GIT_HOST_IP" # test that all will be okay
git clone git@bitbucket.org:joeltd/bigdata.git mirror.bigdata  # this clone against bigdata account and repo is bigdata
```

BITBUCKET_USER=joebloggs276;
# curl --user ${BITBUCKET_USER} https://api.bitbucket.org/2.0/repositories/joeltd
curl --user ${BITBUCKET_USER} git@api.bitbucket.org/2.0/repositories/joeltd


Note that the clone command uses the bitbucket account called joeltd and the repository is called big_data_scripts.

The response to the SSH test against a bitbucket repository for user

`ssh -i /home/joebloggs/.ssh/bitbucket-repo-private-key.pem -vT "joebloggs276@$GIT_HOST_IP"`

## Setup Git in Existing Directory

To hook up with a new repository from a directory with files you first

- create the remote repository (use safe's github and gitlab tooling)
- safe will have created a public / private keypair and installed it in the remote repo
- locally their should be a private key (with 0600 permissions) and an entry in ~/.ssh/config
- go to the git directory (without a .git folder)

The commands to run

git init
git add -A
git status
git commit -am "First checkin of project."
git remote add origin git@<<Host>>:<<userOrGroup>>/<<repo-name>>.git
git remote -v
git push --set-upstream origin master

=end

    end


  end


end
