#!/usr/bin/ruby
	
module SafeDb

  # This class gives a flavour of setting up a git repository to be accessed
  # with PUBLIC / PRIVATE keys (using SSH) rather than via a GitHub access token
  # that uses HTTPS (see remote.rb).
  #
  # THIS IMPLEMENTATION IS AS YET UNFINISHED BECAUSE IT DOES NOT WRITE INTO THE
  # SSH CONFIG FILE IN ~/.ssh/config
  #
  # A number of setup tasks are executed when you ask that the backend repository be created.
  #
  # - a repository is created in github
  # - the git fetch (https) and git push (ssh) urls are fabricated
  # - the fetch url is written into the master keys file
  # - the push url is written to the configured chapter/verse location
  # - a ssh public/private keypair (using EC25519) is created
  # - the private and public keys are placed within the chapter/verse
  # - the public (deploy) key is registered with the github repository
  #
  class RemoteGithubKeypair < EditVerse

    attr_writer :provision

    # We want to provision (create) the safe's remote (github) backend.
    # A number of setup tasks are executed when you ask that the backend repository be created.
    def edit_verse()

      return unless @provision

      github_access_token = @verse[ Indices::GITHUB_ACCESS_TOKEN ]
      return unless is_github_access_token_valid( github_access_token )

      repository_name = "safe-#{TimeStamp.yyjjj_hhmm_sst()}"
      @verse.store( Indices::GIT_REPOSITORY_NAME_KEYNAME, repository_name )
      private_key_simple_filename = "safe.#{@book.get_open_chapter_name()}.#{@book.get_open_verse_name()}.#{TimeStamp.yyjjj_hhmm_sst()}"
      @verse.store( Indices::REMOTE_PRIVATE_KEY_KEYNAME, "#{private_key_simple_filename}.pem" )
      @verse.store( Indices::REMOTE_MIRROR_SSH_HOST_KEYNAME, "safe-#{TimeStamp.yyjjjhhmmsst()}" )

      remote_mirror_page = "#{@book.book_id()}/#{@book.get_open_chapter_name()}/#{@book.get_open_verse_name()}"
      Master.new().set_backend_coordinates( remote_mirror_page )

      key_creator = Keys.new()
      key_creator.set_verse( @verse )
      key_creator.keyfile_name = private_key_simple_filename
      key_creator.edit_verse()
      repo_public_key = @verse[ Indices::PUBLIC_KEY_DEFAULT_KEY_NAME ]

# @todo - refactor into GitHub integration class
# @todo - refactor into GitHub integration class
# @todo - refactor into GitHub integration class
# @todo - refactor into GitHub integration class
# @todo - refactor into GitHub integration class
# @todo - refactor into GitHub integration class
# @todo - refactor into GitHub integration class

      require "etc"
      require "socket"
      require "octokit"

      github_client = Octokit::Client.new( :access_token => github_access_token )
      github_user = github_client.user
      repo_creator = "#{ENV[ "USER" ]}@#{Socket.gethostname()}"
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
      puts "SSH Public Key   =>  #{repo_public_key[0..40]}..."

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
      github_client.add_deploy_key( repository_id, "your safe crypt deployment key with ID #{TimeStamp.yyjjj_hhmm_sst()}", repo_public_key )

    end


    def is_github_access_token_valid( github_access_token )

      is_invalid = github_access_token.nil?() || github_access_token.strip().length() < GITHUB_TOKEN_MIN_LENGTH
      puts "No valid github access token found." if is_invalid
      return !is_invalid

    end

    GITHUB_TOKEN_MIN_LENGTH = 7


  end


end
