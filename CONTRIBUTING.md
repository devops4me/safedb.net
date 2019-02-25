
# How to Contribute to the Safe

You can contriubute software, documentation, issues and even good ideas. Most contributions will either be integrations with other tools and technologies, or new use cases (plugins).

## Contributing Software

To contribute software you'll need to setup a development environment.

```
sudo apt-get install --assume-yes ruby-full, libicu-dev, git
sudo chown -R $USER:$USER /var/lib/gems
sudo chown -R $USER:$USER /usr/local/bin
gem install safedb bundler
git clone https://github.com/devops4me/safedb.net.git mirror.safedb.ro
cd mirror.safedb
rake install
```

You change the software as you see fit and **send a pull request** when you are ready.

## Releasing Software

Those with priveleges to release to safedb.net will have
- a github ssh private key (matching the installed devops4me/safedb.net public key)
- username and password credentials for releasing **safedb** to **rubygems.org**.

You will also know the semantic versioning principles for rolling forward the safedb gem version.

### Releasing to GitHub and RubyGems.org

The steps to release a safe version using safe itself are

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
# Change the major, minor or patch version
git config --global user.email "<<email@address>>"
git config --global user.name "<<Your Name>>"
git push -u origin master
```

If a config file already exists then safe will back it up with a timestamp prefix before clobbering the file.

