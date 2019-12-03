FROM ruby:latest

# --->
# ---> install the gems necessary to build test package and
# ---> release this ruby project.
# --->

RUN gem install bundler gem-release cucumber aruba yard

# --->
# ---> Create a workspace for the ruby project and then
# ---> recursively pull it into the image.
# --->

RUN mkdir -p /project
WORKDIR /project
COPY . .
RUN chmod u+x /project/cucumber-build-script.sh

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

# --->
# ---> 
# ---> Use cucumber and aruba to find and execute all features
# ---> recursively found under the lib directory.
# --->

ENTRYPOINT [ "/project/cucumber-build-script.sh" ]
