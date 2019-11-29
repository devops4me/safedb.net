FROM ruby:latest

RUN apt-get update && apt-get --assume-yes install -qq -o=Dpkg::Use-Pty=0 \
      tree

# --->
# ---> install the gems necessary to build test package and
# ---> release this ruby project.
# --->

RUN gem install bundler gem-release cucumber aruba yard

# --->
# ---> Recursively pull in the ruby project.
# --->

RUN mkdir -p /project
WORKDIR /project
COPY . .
RUN tree -d

# --->
# ---> use rake to build and install the gem then use cucumber
# ---> and aruba to run the behaviour driven tests
# --->

RUN bundle install && rake install && cucumber
