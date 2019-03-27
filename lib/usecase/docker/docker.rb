#!/usr/bin/ruby
	
module SafeDb

    # This docker use case handles the ...
    #
    #     safe docker login
    #     safe docker logout

    class Docker < UseCase

        # The command which currently must be login, logout or
        # an empty string.
        attr_writer :command

        def execute

            return unless ops_key_exists?
            master_db = get_master_database()
            return if unopened_envelope?( master_db )

            # Get the open chapter identifier (id).
            # Decide whether chapter already exists.
            # Then get (or instantiate) the chapter's hash data structure
            chapter_id = ENVELOPE_KEY_PREFIX + master_db[ ENV_PATH ]
            verse_id = master_db[ KEY_PATH ]
            chapter_exists = KeyApi.db_envelope_exists?( master_db[ chapter_id ] )

            # Unlock the chapter data structure by supplying
            # key/value mini-dictionary breadcrumbs sitting
            # within the master database at the section labelled
            # envelope@<<actual_chapter_id>>.
            chapter_data = KeyStore.from_json( Lock.content_unlock( master_db[ chapter_id ] ) )

            key_value_dictionary = chapter_data[ verse_id ]
            docker_username = key_value_dictionary[ "docker.username" ]
            docker_password = key_value_dictionary[ "@docker.password" ]
            docker_login_cmd = "docker login --username #{docker_username} --password #{docker_password} 2>/dev/null"
            docker_logout_cmd = "docker logout"
            docker_cmd = @command.eql?( "logout" ) ? docker_logout_cmd : docker_login_cmd
            system docker_cmd

        end


    end


end
