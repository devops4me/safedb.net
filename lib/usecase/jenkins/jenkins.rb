#!/usr/bin/ruby
	
module SafeDb

    # This Jenkins use case handles the to and fro integration of secrets and sensitive information
    # between the safe database under management and a Jenkins service pinpointed by an incoming 
    # host url parameter.
    #
    # This Jenkins use case injects for example the AWS IAM user access key, secret key and region key
    # into a running Jenkins CI (Continuous Integration) service at the specified (url) location.
    #
    #     safe jenkins post <<[ aws | docker | git ]>> <<jenkins-host-url>>

    class Jenkins < UseCase

        # The three instance variables provided through the command line like
        # for example  $ safe jenkins post aws http://localhost:8080
        # For more info visit the documentation in the command interpreter class.
        attr_writer :command, :service, :url

        # If string variables EXPLODE throughout (and come to dominate) this class
        # we should consider introducing an INI factfile like the [vpn] use case.
        JENKINS_URI_PATH = "credentials/store/system/domain/_/createCredentials"

        # If string variables EXPLODE throughout (and come to dominate) this class
        # we should consider introducing an INI factfile like the [vpn] use case.
        SECRET_KEY_VALUE_PAIR_DICTIONARY =
          {
            "scope"       => "GLOBAL",
            "$class"      => "org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl"
          }

        # If string variables EXPLODE throughout (and come to dominate) this class
        # we should consider introducing an INI factfile like the [vpn] use case.
        SECRET_KEY_VALUE_PAIR_TO_POST = { "" => "0", "credentials" => SECRET_KEY_VALUE_PAIR_DICTIONARY }


        # If string variables EXPLODE throughout (and come to dominate) this class
        # we should consider introducing an INI factfile like the [vpn] use case.
        USERNAME_AND_PASSWORD_DICTIONARY =
          {
            "scope"       => "GLOBAL",
            "$class"      => "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"
          }

        # If string variables EXPLODE throughout (and come to dominate) this class
        # we should consider introducing an INI factfile like the [vpn] use case.
        USERNAME_AND_PASSWORD_TO_POST = { "" => "0", "credentials" => USERNAME_AND_PASSWORD_DICTIONARY }



        # Inject a Jenkins credential key-value pair that is secret and/or sensitive and
        # needs to be referenced by executing continuous integration jobs.
        #
        # @param jenkins_base_url [String]
        #
        #    This base url includes the scheme (protocol) which can be either http
        #    or https. It can include the port if it is not either 80 or 443. A common
        #    example is http://localhost:8080 but can also be https://jenkins.example.com
        #    It pays not to provide a trailing backslash on this url.
        #
        # @param credentials_id [String]
        #
        #    The ID that Jenkins jobs will use to reference this credential's value.
        #
        # @param secret_value [String]
        #
        #    The value of this credential (secret) that will be injected for SafeKeeping
        #    to the Jenkins service at the provided URL.
        #
        # @param description [String]
        #
        #    Description of the credential that will be posted and can be viewed via
        #    the Jenkins user interface.
        def inject_secret_key_value_pair( jenkins_base_url, credentials_id, secret_value, description )

            jenkins_url = File.join( jenkins_base_url, JENKINS_URI_PATH )

            credentials_dictionary = SECRET_KEY_VALUE_PAIR_DICTIONARY
            credentials_dictionary.store( "id", credentials_id )
            credentials_dictionary.store( "secret", secret_value )
            credentials_dictionary.store( "description", description )

            curl_cmd = "curl -X POST '#{jenkins_url}' --data-urlencode 'json=#{SECRET_KEY_VALUE_PAIR_TO_POST.to_json}'"

            puts ""
            puts " - Jenkins Host Url : #{jenkins_url}"
            puts " -   Credentials ID : #{credentials_id}"
            puts " - So what is this? : #{description}"
            puts ""

            %x[ #{curl_cmd} ]

            puts ""

        end



        # Inject into Jenkins a username and password pairing against an ID key that the
        # continuous integration jobs know and can use to access the credentials pair.
        #
        # @param jenkins_base_url [String]
        #
        #    This base url includes the scheme (protocol) which can be either http
        #    or https. It can include the port if it is not either 80 or 443. A common
        #    example is http://localhost:8080 but can also be https://jenkins.example.com
        #    It pays not to provide a trailing backslash on this url.
        #
        # @param credentials_id [String]
        #
        #    The ID that Jenkins jobs will use to reference this credential's value.
        #
        # @param username [String]
        #
        #    The value of this username (secret) that will be injected for SafeKeeping
        #    to the Jenkins service at the provided URL.
        #
        # @param password [String]
        #
        #    The value of this password (secret) that will be injected for SafeKeeping
        #    to the Jenkins service at the provided URL.
        #
        # @param description [String]
        #
        #    Description of the username and password pairing that will be posted and
        #    can be viewed via the Jenkins user interface.
        def inject_username_and_password( jenkins_base_url, credentials_id, username, password, description )

            jenkins_url = File.join( jenkins_base_url, JENKINS_URI_PATH )

            credentials_dictionary = USERNAME_AND_PASSWORD_DICTIONARY
            credentials_dictionary.store( "id", credentials_id )
            credentials_dictionary.store( "username", username )
            credentials_dictionary.store( "password", password )
            credentials_dictionary.store( "description", description )

            curl_cmd = "curl -X POST '#{jenkins_url}' --data-urlencode 'json=#{USERNAME_AND_PASSWORD_TO_POST.to_json}'"

            puts ""
            puts " - Jenkins Host Url : #{jenkins_url}"
            puts " -   Credentials ID : #{credentials_id}"
            puts " -  Inject Username : #{username}"
            puts " - So what is this? : #{description}"
            puts ""

            %x[ #{curl_cmd} ]

            puts ""

        end



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
            chapter_data = KeyDb.from_json( KeyApi.content_unlock( master_db[ chapter_id ] ) )

            key_value_dictionary = chapter_data[ verse_id ]

            inject_aws_credentials(    key_value_dictionary ) if @service.eql?( "aws" )
            inject_docker_credentials( key_value_dictionary ) if @service.eql?( "docker" )

        end



        def inject_aws_credentials( mini_dictionary )

            access_key_desc = "The access key of the AWS IAM (programmatic) user credentials."
            secret_key_desc = "The secret key of the AWS IAM (programmatic) user credentials."
            region_key_desc = "The AWS region key for example eu-west-1 for Dublin in Ireland."

            inject_secret_key_value_pair( @url, "safe.aws.access.key", mini_dictionary[ "@access.key" ], access_key_desc )
            inject_secret_key_value_pair( @url, "safe.aws.secret.key", mini_dictionary[ "@secret.key" ], secret_key_desc )
            inject_secret_key_value_pair( @url, "safe.aws.region.key", mini_dictionary[ "region.key"  ], region_key_desc )

        end


        def inject_docker_credentials( mini_dictionary )

            docker_desc = "The docker repository login credentials in the shape of a username and password."

            inject_username_and_password( @url, "safe.docker.login.id", mini_dictionary[ "docker.username" ], mini_dictionary[ "@docker.password" ], docker_desc )

        end


    end


end
