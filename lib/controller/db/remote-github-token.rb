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
  # Finally prompt the user to issue a commit followed by a push.
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

      repository_user = Github.create_repo( github_access_token, repository_name )
      @verse.store( Indices::GIT_REPOSITORY_USER_KEYNAME, repository_user )

      fetch_url = "https://github.com/#{repository_user}/#{repository_name}.git"
      push_url = "https://#{repository_user}:#{github_access_token}@github.com/#{repository_user}/#{repository_name}.git"
      GitFlow.add_origin_url( Indices::MASTER_CRYPTS_FOLDER_PATH, fetch_url )
      GitFlow.set_push_origin_url( Indices::MASTER_CRYPTS_FOLDER_PATH, push_url )

    end


    def is_github_access_token_valid( github_access_token )

      is_invalid = github_access_token.nil?() || github_access_token.strip().length() < 7
      puts "No valid github access token found." if is_invalid
      return !is_invalid

    end


  end


end
