#!/usr/bin/ruby
	
module SafeDb

    # This docker use case handles the ...
    #
    #     safe docker login
    #     safe docker logout

    class Docker < QueryVerse

        # The command which currently must be login, logout or
        # an empty string.
        attr_writer :command

        def query_verse()

            docker_username = @verse[ "docker.username" ]
            docker_password = @verse[ "@docker.password" ]
            docker_login_cmd = "docker login --username #{docker_username} --password #{docker_password} 2>/dev/null"
            docker_logout_cmd = "docker logout"
            docker_cmd = @command.eql?( "logout" ) ? docker_logout_cmd : docker_login_cmd
            system docker_cmd

        end


    end


end
