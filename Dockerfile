
# FROM ruby:latest
FROM ubuntu:18.04
USER root

# --->
# ---> Setup the key packages dependencies for the ruby gems
# ---> environment and switch on sudo.
# --->

RUN apt-get update && apt-get --assume-yes install -qq -o=Dpkg::Use-Pty=0 \
      ruby-full \
      libicu-dev \
      git \
      sudo

# --->
# ---> install the gems necessary to build, unit test, package and
# ---> release this ruby project.
# --->

RUN gem install bundler gem-release cucumber aruba yard
RUN gem install rake -v '12.3.3' --source 'https://rubygems.org/'
RUN gem install public_suffix -v '4.0.1' --source 'https://rubygems.org/'
RUN gem install addressable -v '2.7.0' --source 'https://rubygems.org/'
RUN gem install childprocess -v '1.0.1' --source 'https://rubygems.org/'
RUN gem install aruba -v '1.0.0.pre.alpha.4' --source 'https://rubygems.org/'
RUN gem install bcrypt -v '3.1.13' --source 'https://rubygems.org/'
RUN gem install multipart-post -v '2.1.1' --source 'https://rubygems.org/'
RUN gem install faraday -v '0.17.1' --source 'https://rubygems.org/'
RUN gem install inifile -v '3.0.0' --source 'https://rubygems.org/'
RUN gem install net-ssh -v '5.2.0' --source 'https://rubygems.org/'
RUN gem install sawyer -v '0.8.2' --source 'https://rubygems.org/'
RUN gem install octokit -v '4.14.0' --source 'https://rubygems.org/'


# --->
# ---> Note - there is VALUE in creating a non-root user and using
# ---> them to operate the safe as opposed to a root user.
# --->
# ---> Create a sudoer(able) safe verification user called safetty
# ---> and continue as them.
# --->

RUN adduser --home /var/opt/safetty --shell /bin/bash --gecos 'Safe TTY Test User' safetty
RUN install -d -m 755 -o safetty -g safetty /var/opt/safetty
## RUN usermod -a -G sudo safetty

## RUN adduser --home /var/opt/safetty --shell /bin/bash --gecos 'Safe TTY Test User' safetty && \
##     install -d -m 755 -o safetty -g safetty /var/opt/safetty && \
##     usermod -a -G sudo safetty

### ----> RUN echo "safetty:s4f3p455w0rd" | sudo chpasswd

### RUN sudo cat /etc/shadow


### sudo adduser myuser --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
### echo "myuser:password" | sudo chpasswd

RUN chown -R safetty:safetty /var/lib/gems
RUN chown -R safetty:safetty /usr/local/bin
RUN chown -R safetty:safetty /usr/local/lib


RUN mkdir -p /var/opt/safetty/software
COPY . /var/opt/safetty/software/
RUN chown -R safetty:safetty /var/opt/safetty/software

USER safetty
WORKDIR /var/opt/safetty/software

# --->
# ---> Create a workspace for the ruby project and then
# ---> recursively pull it into the image.
# --->

# --->COPY .bash_aliases ~/.bash_aliases
# --->source .bash_aliases

# ---> WORKDIR /project
RUN pwd
RUN ls -lah
# -----> RUN chmod u+x /project/.bash_aliases

# --->
# ---> Use rake to create a single file rubygem package from
# ---> the software project at this point in time.
# --->

RUN rake install
RUN chmod u+x /var/opt/safetty/software/bin/safe
RUN chmod u+x /var/opt/safetty/software/cucumber-build-script.sh

# --->
# ---> Run bundler to download and install the gems specified
# ---> in the gemspec for the project.
# --->

RUN bundle install


# -----> RUN printenv
# -----> RUN . /project/.bash_aliases
# -----> RUN printenv
# -----> RUN export SAFE_TTY_TOKEN=$(safe token)
# -----> RUN printenv
# -----> RUN safe token ; echo

# --->
# ---> 
# ---> Use cucumber and aruba to find and execute all features
# ---> recursively found under the lib directory.
# --->

ENTRYPOINT [ "/var/opt/safetty/software/cucumber-build-script.sh" ]
