FROM ruby:latest

# --->
# ---> install the gems necessary to build test package and
# ---> release this ruby project.
# --->

RUN gem install bundler gem-release cucumber aruba yard

Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue
Tactic - sack this debian rubbish - install Ubuntu in the dockerfile then continue

# --->
# ---> Create a workspace for the ruby project and then
# ---> recursively pull it into the image.
# --->

# --->COPY .bash_aliases ~/.bash_aliases
# --->source .bash_aliases
RUN mkdir -p /project
WORKDIR /project
RUN pwd
COPY . .
RUN ls -lah
RUN chmod u+x /project/.bash_aliases

# --->
# ---> Run bundler to download and install the gems specified
# ---> in the gemspec for the project.
# --->

RUN bundle install


# --->
# ---> Use rake to create a single file rubygem package from
# ---> the software project at this point in time.
# --->

RUN rake install
RUN printenv
RUN . /project/.bash_aliases
RUN printenv
RUN export SAFE_TTY_TOKEN=$(safe token)
RUN printenv
RUN safe token ; echo

# --->
# ---> 
# ---> Use cucumber and aruba to find and execute all features
# ---> recursively found under the lib directory.
# --->

RUN cucumber lib
