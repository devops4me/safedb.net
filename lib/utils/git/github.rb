#!/usr/bin/ruby

module SafeDb


    # The Github class uses the REST API to talk to Github and create, query,
    # change and delete assets within a specified hosted git repository.
    #
    # Note that you can ply the new github repository with a SSH public key
    # so that those who know the corresponding private key can post to it. To do
    # this a repository ID in the format user_name/repository_name must be
    # provided.
    #
    #    repository_id = "#{github_user[:login]}/#{repository_name}"
    #    github_client.add_deploy_key( repository_id, "key description", repo_public_key )
    #
    class Github


        # Create a github git repository when given an access token and the
        # required repository name.
        #
        # @param github_access_token [String] hexadecimal github access token
        # @param repository_name [String] name of he non-existent repository to create
        # @return [String] name of the github user
        def self.create_repo( github_access_token, repository_name )

            require "etc"
            require "socket"
            require "octokit"

            github_client = Octokit::Client.new( :access_token => github_access_token )
            github_user = github_client.user
            repo_creator = "#{Etc.getlogin()}@#{Socket.gethostname()}"
            repo_description = "This github repository was auto-created by safedb.net to be a remote database backend on behalf of #{repo_creator} on #{TimeStamp.readable()}."
            repo_homepage = "https://github.com/devops4me/safedb.net/"

            puts ""
            puts "Repository Name  =>  #{repository_name}"
            puts "Github Company   =>  #{github_user[:company]}"
            puts "Account Owner    =>  #{github_user[:name]}"
            puts "Github User ID   =>  #{github_user[:id]}"
            puts "Github Username  =>  #{github_user[:login]}"

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
            return github_user[:login]

        end


    end

end

