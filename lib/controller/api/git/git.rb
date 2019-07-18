#!/usr/bin/ruby
	
module SafeDb

  class Git < QueryVerse

    # If the --clone switch is included this class will expect to be at a verse
    # that contains either a github token, username, reponame combination or a
    # publicly publicly clonable url, or ssh url with the private keys and SSH host
    # configuration already setup.
    attr_writer :clone

    # If the --push switch is included this class will expect to be at a verse
    # that has a path to a git url within it. If this is missing the present working
    # directory is assumed to be the git repository in question.
    #
    # If the verse contains a branch name which is not the current branch then
    # we raise a query to the user instead of pushing to the wrong place. This is
    # a good double (sanity) check.
    attr_writer :push

    # If the --push switch is included this class will expect to be at a verse
    # that has a path to a git url within it. If this is missing the present working
    # directory is assumed to be the git repository in question.
    attr_writer :pull

    # If the --no-ssl-verify switch is passed into this class it will urge git not
    # to worry when a site does not have a (presently) trusted SSL certificate.
    attr_writer :no_ssl_verify

    # If the --to switch has a value which is a path to a local (possibly non-existing)
    # folder to clone to - this will override the verse line git.clone.path
    attr_writer :to


    def query_verse()

      puts ""

      require "octokit"

      git_repository_name = @verse[ Indices::GIT_REPOSITORY_NAME_KEYNAME ]
      git_repository_user = @verse[ Indices::GIT_REPOSITORY_USER_KEYNAME ]
      git_repository_host = @verse[ Indices::GIT_REPOSITORY_HOST_KEYNAME ]
      git_repository_id = "#{git_repository_user}/#{git_repository_name}"

=begin
      # Clone repo using the github token
      github_access_token = @verse[ Indices::GITHUB_ACCESS_TOKEN ]
      git_repository_url = "https://#{github_access_token}@github.com/#{git_repository_id}"
=end

      # Clone repo using a SSH public/private keypair
      git_repository_url = "git@#{git_repository_host}:#{git_repository_id}"
      non_existent_path = File.join( get_clone_directory(), git_repository_name )

      log.info(x) { "[gitflow] cloning remote repository called #{git_repository_name}" }
      log.info(x) { "[gitflow] git repository user : #{git_repository_user}" }
      log.info(x) { "[gitflow] git repository host : #{git_repository_host}" }
      log.info(x) { "[gitflow] git repository clone path : #{non_existent_path}" }

      git_clone_cmd = "git clone #{git_repository_url} #{non_existent_path}"
      git_clone_output = %x[ #{ git_clone_cmd } ]
      log.info(x) { "[gitflow] git clone output   : #{git_clone_output}" }

      puts ""

    end


    # The git clone directory destination can be deemed from one of 3 places with
    # the precedence order shown below.
    #
    # - the --to switch passed on the command line
    # - the GIT_CLONE_BASE_PATH keyname within indices
    # - the present working directory
    #
    # This method returns a File object which it could possibly create if the
    # first two options denote a path that does not exist (but could).
    #
    # Failure is not yet handled but should be.
    def get_clone_directory()

      if @to
        folder_exists = File.directory?( @to )
        FileUtils.mkdir_p( @to ) unless folder_exists
        return @to
      end

      if @verse.has_key?( Indices::GIT_CLONE_BASE_PATH )
        folder_exists = File.directory?( @verse[ Indices::GIT_CLONE_BASE_PATH ] )
        FileUtils.mkdir_p( @verse[ Indices::GIT_CLONE_BASE_PATH ] ) unless folder_exists
        return @verse[ Indices::GIT_CLONE_BASE_PATH ]
     end

      return Dir.pwd()

   end


  end


end
