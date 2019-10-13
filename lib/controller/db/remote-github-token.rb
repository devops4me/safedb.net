#!/usr/bin/ruby
	
module SafeDb

  # This class uses Github (https) along with an access token (as opposed to ssh keypairs)
  # to provision a remote backend for a safe database.
  #
  # == Github Access Token
  #
  # The safe book must be opened at a chapter/verse that contains a line named
  # `@github.access.token` with a viable token value. This is the only pre-condition to
  # the `safe remote --provision` command.
  #
  # == Flow of Events
  #
  # To provision a Github token-based remote backend for the safe database means
  #
  # - a repository is created in github
  # - the repository name and user are stored in the verse
  # - the fetch/pull/clone url is put into configuration visible before login
  # - the push origin url is added using the `git remote add origin` command
  #
  # The user is now prompted to wrap things up by issuing the following commands.
  #
  #     safe commit
  #     safe push
  #
  class RemoteGithubToken < EditVerse

    attr_writer :provision

    # We want to provision (create) the safe's remote (github) backend.
    # A number of setup tasks are executed when you ask that the backend repository be created.
    def edit_verse()

      return unless @provision

      github_access_token = @verse[ Indices::GITHUB_ACCESS_TOKEN ]
      return unless is_github_access_token_valid( github_access_token )

      repository_name = "safe-#{TimeStamp.yyjjj_hhmm_sst()}"
      @verse.store( Indices::GIT_REPOSITORY_NAME_KEYNAME, repository_name )

      # We could hardcode this to genesis:remote/github which will be
      # referenced only on the first ever safe pull --from=https://github.com/devops4me/safe-xxxx
      # This is required for setting the push origin url.
      remote_mirror_page = "#{@book.book_id()}/#{@book.get_open_chapter_name()}/#{@book.get_open_verse_name()}"
      Master.new().set_backend_coordinates( remote_mirror_page )

# @todo - refactor into GitHub integration class
# @todo - refactor into GitHub integration class
# @todo - refactor into GitHub integration class

      require "etc"
      require "socket"
      require "octokit"

      github_client = Octokit::Client.new( :access_token => github_access_token )
      github_user = github_client.user
      repo_creator = "#{Etc.getlogin()}@#{Socket.gethostname()}"
      repo_description = "This github repository was auto-created by safedb.net to be a remote database backend on behalf of #{repo_creator} on #{TimeStamp.readable()}."
      repo_homepage = "https://github.com/devops4me/safedb.net/"
      repository_id = "#{github_user[:login]}/#{repository_name}"
      @verse.store( Indices::GIT_REPOSITORY_USER_KEYNAME, github_user[:login] )

      puts ""
      puts "Repository Name  =>  #{repository_id}"
      puts "Github Company   =>  #{github_user[:company]}"
      puts "Account Owner    =>  #{github_user[:name]}"
      puts "Github User ID   =>  #{github_user[:id]}"
      puts "Github Username  =>  #{github_user[:login]}"

##############      puts "SSH Public Key   =>  #{repo_public_key[0..40]}..."

      puts "Creation Entity  =>  #{repo_creator}"
      puts "Repo Descriptor  =>  #{repo_description}"
      puts "Repo Homepage    =>  #{repo_homepage}"
      puts ""

      options_hash = {
        :description => repo_description,
        :repo_homepage => repo_homepage,
        :private => false,
        :has_issues => false,
        :has_wiki => false,
        :has_downloads => false,
        :auto_init => false
      }

      github_client.create_repository( repository_name, options_hash  )

####################      github_client.add_deploy_key( repository_id, "your safe crypt deployment key with ID #{TimeStamp.yyjjj_hhmm_sst()}", repo_public_key )

    end


    def is_github_access_token_valid( github_access_token )

      is_invalid = github_access_token.nil?() || github_access_token.strip().length() < GITHUB_TOKEN_MIN_LENGTH
      puts "No valid github access token found." if is_invalid
      return !is_invalid

    end

    GITHUB_TOKEN_MIN_LENGTH = 7


  end


end
