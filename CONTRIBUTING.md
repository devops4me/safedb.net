
# How to Contribute to the Safe

You can contriubute software, documentation, issues and even good ideas. Most contributions will either be integrations with other tools and technologies, or new use cases (plugins).


## Contributing Software

To contribute software you'll need to setup a development environment.

```
sudo apt-get install --assume-yes ruby-full libicu-dev git
sudo chown -R $USER:$USER /var/lib/gems
sudo chown -R $USER:$USER /usr/local/bin
sudo chown -R $USER:$USER /usr/local/lib
gem install safedb bundler gem-release cucumber aruba
git clone https://github.com/devops4me/safedb.net.git mirror.safedb.ro
cd mirror.safedb
rake install
bundle install
```

You change the software as you see fit and **send a pull request** when you are ready.


## Releasing Software

Those with priveleges to release to safedb.net will have a private key to push (or pull) in git repository changes.

To release the software to the rubygems.org platform, commonly via a **continuous integration pipeline** based on Jenkins 2.0, one needs

- **either** the email address / password combination
- **or** a credentials file containing a hex API key

Release actors are also responsible for bumping the gem version via semantic versioning principles.

### git push to github.com/devops4me/safedb.net

Write out the SSH config and private key files.

```
safe login safe.ecosystem
safe open <<chapter>> <<verse>>
cd ~/.ssh
safe eject github.ssh.config
safe eject safedb.code.private.key
chmod 600 safedb.code.private.key
cd <<repositories-folder>>
ssh -i ~/.ssh/safedb.code.private.key.pem -vT git@safedb.code
git clone git@safedb.code:devops4me/safedb.net.git mirror.safedb.code
```

If a config file already exists then safe will back it up with a timestamp prefix before clobbering the file. Now bump up the major, minor or patch versions, then commit.

### development installs | rake install

Use rake install to locally test local software changes.

### bump | tag | release to RubyGems.org

Once only use **`gem push`** at the repository root to create a **rubygems API key** and slurp it up from the **`~/.gem/credentials`** with **`safe file rubygems.org.credentials ~/.gem/credentials`**
Now when releasing we eject the file back into **`~/.gem/credentials`**, secure it ( with **`sudo chmod 0600 credentials`** ) and then issue the below command from the **gem-release** gem.

### `gem bump patch --tag --push --release --file=$PWD/lib/version.rb`

This command bumps up the patch (or major or minor) version, tags the repository, pushes the changes and releases to rubygems.org
