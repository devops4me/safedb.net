FROM ruby:latest

# --->
# ---> install the gems necessary to build test package and
# ---> release this ruby project.
# --->

RUN gem install gem-release cucumber aruba yard


# --->
# ---> Create a non-root user from which to execute the cucumber
# ---> and aruba command line behaviour features.
# --->

RUN adduser --home /home/safeci --shell /bin/bash --gecos 'Safe TTY Test User' safeci && \
  install -d -m 755 -o safeci -g safeci /home/safeci


# --->
# ---> Create a workspace for the ruby project and then
# ---> recursively COPY the artifacts into the image.
# --->

COPY . /home/safeci/software/


RUN chown -R safeci:safeci /home/safeci
RUN chmod u+x /home/safeci/software/cucumber-build-script.sh

RUN cd /home/safeci/software; rake install

USER safeci
WORKDIR /home/safeci/software




# --->
# ---> 
# ---> Use cucumber and aruba to find and execute all features
# ---> recursively found under the lib directory.
# --->

ENTRYPOINT [ "/home/safeci/software/cucumber-build-script.sh" ]
