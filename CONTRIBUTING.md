
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

Those with priveleges to release to safedb.net will have a private key to push (or pull) in git repository changes.

To release the software to the rubygems.org platform, commonly via a **continuous integration pipeline** based on Jenkins 2.0, one needs

- **either** the email address / password combination
- **or** a hexadecimal rubygems API key

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


### rake release RubyGems.org

Use **`gem push`** at the repository root to create a **rubygems API key** and slurp it up from the **`~/.gem/credentials`** file. It pays to put it into the safe against a key called **`@rubygems.api.key`**.

Usually releases will be done within the **Jenkinsfile** with the **GEM_HOST_API_KEY** exported into the environment. Manually, it can be done like this.

```
export GEM_HOST_API_KEY=`safe print @rubygems.api.key`
```

Finally, this is how one pushes up the latest gem changes.

```
git push -u origin master
rake install
rake release
```
