
# How to Contribute to the Safe

You can contriubute software, documentation, issues and even good ideas. Most contributions will either be integrations with other tools and technologies, or new use cases (plugins).

**Ignore these instructions if you just want to use the software.** To **use the software** **[visit the readme](README.md)**.


---


## Use Docker to Build and Run the Tests

Using **`docker`** is the **simplest quickest** way to **build, package** and run the **cucumber/aruba** test suite.

```
# Get the safe software
git clone https://github.com/devops4me/safedb.net.git
cd safedb.net

# Prepare the safe build docker image
docker build --tag img.safeci .

# Now run the safe build docker image
docker run           \
    --interactive    \
    --tty            \
    --rm             \
    --name vm.safeci \
    img.safeci
```


---


## Ubuntu 18.04 | 20.04 Development Environment

To contribute software from an Ubuntu client you'll need to setup a development environment with steps similar to these.

```
sudo apt install --assume-yes ruby-full libicu-dev
sudo chown -R $USER:$USER /var/lib/gems
sudo chown -R $USER:$USER /usr/local/bin
sudo chown -R $USER:$USER /usr/local/lib
gem install bundler gem-release cucumber aruba yard
git clone https://github.com/devops4me/safedb.net.git mirror.safedb.ro
cd mirror.safedb
rake install
bundle install
cucumber
```

Now you change the software as you see fit and **send a pull request** when you are ready.

## MacOS Development Environment

These are the steps to contribute software from a MacBook Linux environment. See the RubyMine wiki page to help setup the environment using the RubyMine IDEA development suite.

The MacOS comes with Ruby, rake and bundler pre-installed.

```
gem --version
sudo apt install --assume-yes ruby-full libicu-dev
sudo chown -R $USER:$USER /var/lib/gems
sudo chown -R $USER:$USER /usr/local/bin
sudo chown -R $USER:$USER /usr/local/lib
sudo gem install gem-release cucumber aruba yard
git clone https://github.com/devops4me/safedb.net.git
cd safedb.net
sudo rake install
safe --version
bundle install
cucumber
```

You change the software as you see fit and **send a pull request** when you are ready.


## Cucumber and Aruba | Installi the right version

Aruba and Cucumber are **finickity** about both each others versions and the ruby version. If you see this output in the gem install command you need to act.

```
Fetching: aruba-0.14.12.gem (100%)
Use on ruby 1.8.7
* Make sure you add something like that to your `Gemfile`. Otherwise you will
  get cucumber > 2 and this will fail on ruby 1.8.7

  gem 'cucumber', '~> 1.3.20'

With aruba >= 1.0 there will be breaking changes. Make sure to read https://github.com/cucumber/aruba/blob/master/History.md for 1.0.0
Successfully installed aruba-0.14.12
```


## Running Cucumber/Aruba Tests

Use the simple **`cucumber`** command in the project directory to run the tests.

## Reek | Ruby Code Quality

software quality must improve with every check-in and conversely we should never holistically degrade quality. Every change must be small and incremental so keeping the quality metrics ticking in the right direction is not too much to ask.

**[reek code quality documentation](https://github.com/troessner/reek/tree/v5.3.1/docs)**

We must **install and run reek** within development and continuous integration pipelines, so as to derive a listing of software quality issues.

```
gem install reek
reek lib
```


## Automated Software Release

safedb is automatically released by Jenkins using a GitOps style pipeline defined in the **[Jenkinsfile]** and **[Dockerfile]**. The release to rubygems.org depends on

- a pull request to the [safe github master branch](https://github.com/devops4me/safedb.net.git)
- an error-free gem build
- an error-free documentation image build to www.safedb.net
- immaculate BDD test runs with **Cucumber and Aruba** in Linux environments incl Ubuntu, Raspbian and RHEL.
- an automated version number bump using the gem-release gem
- quality numbers passed by the Reek code quality analyzer
- available rubygems.org credentials in ~/.gem/credentials

## Release to RubyGems.org

Once only use **`gem push`** at the repository root to create a **rubygems API key** and slurp it up from the **`~/.gem/credentials`** with **`safe file rubygems.org.credentials ~/.gem/credentials`**
Now when releasing we eject the file back into **`~/.gem/credentials`**, secure it ( with **`sudo chmod 0600 credentials`** ) and then issue the below command from the **gem-release** gem.

### `gem bump patch --tag --push --release --file=$PWD/lib/version.rb`

### `gem bump patch --tag --push --file=$PWD/lib/version.rb`

The gem bump (and release) command bumps up the patch (or major or minor) version, tags the repository, pushes the changes and releases to rubygems.org

## Specify Safe Data Directory

The safe keeps its local data by default within `$HOME/.config/safedb` and it can sync to any local or remote git repository so that credentials can be shared between machines and even users.

However you can change this location during development by setting the environment variable **`SAFEDB_DATA_DIRECTORY`**


## Common Development Commands

These commands will be used frequently while developing the safe.

- `rake install`
- `cucumber`
- `git checkout -b feature.verb-noun`
- `git add; git commit;`
- `git cherry -v origin`
- `git cherry -v origin feature.verb-noun`
- `git push -u origin feature.verb-noun`
- `git pull origin master`
- `git pull origin feature.verb-noun`

When ready to merge the feature development branch into master these commands will be used.

- `git checkout master`
- `git pull origin master`
- `git merge feature.verb-noun`
- `git push origin master`


## Branch Naming Convention

Branch names begin with either

- feature. (or)
- bug. (or)
- refactor.

Branch names are then typically a **verb-noun concatenation** like

- feature.copy-paste
- bug.login-error
- refactor.cucumber-features

## git push to github.com/devops4me/safedb.net

Those with priveleges to release to safedb.net will have a private key to push pull requests into the repository.

Described here is setting up the **ssh config**, the **pem private key**, then cloning the repository with https, creating a branch, merging and finally pusing using **git ssh**.

```
safe login safe.ecosystem
safe open <<chapter>> <<verse>>
cd ~/.ssh
safe eject github.ssh.config
safe eject safedb.code.private.key
chmod 600 safedb.code.private.key.pem
cd <<repositories-folder>>
ssh -i ~/.ssh/safedb.code.private.key.pem -vT git@safedb.code
git clone https://github.com/devops4me/safedb.net safedb.net
git remote set-url --push origin git@safedb.code:devops4me/safedb.net.git
```

If a config file already exists then safe will back it up with a timestamp prefix before clobbering the file. Now bump up the major, minor or patch versions, then commit.

## Continuous Integration using Jenkins 2.0 Docker Pipeline

safedb.net has Dockerfiles through which the Cucumber/Aruba BDD (behaviour driven development) tests are run within

- **Ubuntu 16.04 and 18.04**
- Raspbian
- **RedHat Enterprise Linux (RHEL)**
- CoreOS containers


### Pipeline Pre-Conditions

The pipeline runs on a Kubernetes platform. The deploy phase depends on the **[Rubygems.org credentials file mounted as a kubernetes secret](https://github.com/devops4me/kubernetes-pipeline)**.


### CI/CD Pipeline from Git to RubyGems.org

The [Jenkinsfile] pipeline definition ensures that succesful builds, quality inspection and tests result in a new version of the software being released to RubyGems.org. In the main the steps are

- use the [rubygem build image in Dockerhub](https://hub.docker.com/repository/docker/devops4me/rubygem) to run reek static code analysis
- use the same image to run Cucumber / Aruba command line system tests
- pipeline ends **unless the branch is origin/release** (current implementation incorrectly specifies NOT origin/master)
- copy mounted credentials to **`~/.gem/credentials`** and lock down the file permissions
- use rake release to push the [latest version](lib/version.rb) of the safe gem

When Kubernetes mounts a secret it makes the entire space read only which can disrupt any software legitimately writing to the mounted path. This is why the secret is not directly mounted into the **`~/.gem/`** directory.

### The Git Release Script

The [git-release.sh] script is run when a human being feels the software state is worth publishing. If so the steps are to

- commit and push to master
- change [lib/version.rb] to increment the **major** or **minor** versions
- run **`./git-release.sh`**

The git release script bumps up the patch version and forwards the origin/release branch to bring it up to date with master and pushes thus triggering the pipeline which in turn goes the extra mile to **[release the safe to Rubygems.org](https://rubygems.org/gems/safedb)**.
