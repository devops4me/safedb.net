FROM ruby:latest

# --->
# ---> install the gems necessary to build test package and
# ---> release this ruby project.
# --->

RUN gem install gem-release cucumber aruba yard reek


# --->
# ---> Create a non-root user from which cucumber and aruba
# ---> orchestrate and validate command line behaviour.
# --->

RUN adduser --home /home/safeci --shell /bin/bash --gecos 'Safe TTY Test User' safeci && \
  install -d -m 755 -o safeci -g safeci /home/safeci

RUN chown -R safeci:safeci /home/safeci

# --->
# ---> 
# ---> As the safeci user employ cucumber and aruba to recursively
# ---> find and execute all cucumber (*.feature) files under lib.
# --->

USER safeci
WORKDIR /home/safeci/code




# ----------------->
# ----------------->
# -----------------> The plan is to replace above safeci wity rubyist (chemist, scientist, dentist)
# -----------------> and let Dockerhub build the image as it is now global to ruby projects.
# ----------------->
# ----------------->
# ----------------->

# --->
# ---> Copy the project assets into the docker image.
# --->

# -----------------> COPY . /home/safeci/code/


# --->
# ---> Use rake to Copy the project assets into the docker image.
# --->

# -----------------> RUN chown -R safeci:safeci /home/safeci && \
# ----------------->         cd /home/safeci/code && \
# -----------------> 	  rake install


