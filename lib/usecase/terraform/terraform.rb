#!/usr/bin/ruby
	
module SafeDb

  # This terraform use case exports the AWS IAM user access key, secret key and region key
  # into (very safe) environment variables and then runs terraform init, plan, apply or destroy.
  #
  # This is both ultra secure and extremely convenient because the credentials do not leave
  # the safe and exist within (environment variable) memory only for the duration of the
  # terraform command.
  #
  # It is safe because you do not need to expose your AWS credentials in plain text.
  # It is convenient because switching IAM users and AWS regions is as easy as typing the now
  # ubiquitous safe open command.
  #
  #     safe open <<chapter>> <<verse>>
  class Terraform < UseCase

    attr_writer :command

    # This prefix is tagged onto environment variables which Terraform will read
    # and convert for consumption into module input variables.
    TERRAFORM_EVAR_PREFIX = "TF_VAR_"

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


      # -- @todo begin
      # -- Throw an exception (error) if the chapter
      # -- either exists and is empty or does not exist.
      # -- @todo end


      # Unlock the chapter data structure by supplying
      # key/value mini-dictionary breadcrumbs sitting
      # within the master database at the section labelled
      # envelope@<<actual_chapter_id>>.
      chapter_data = KeyStore.from_json( KeyApi.content_unlock( master_db[ chapter_id ] ) )

      # Now read the three AWS IAM credentials @access.key, @secret.key and region.key
      # into the 3 environment variables terraform expects to find.

      # ############## | ############################################################
      # @todo refactor | ############################################################
      # -------------- | 000000000000000000000000000000000000000000000000000000000000
      # export-then-execute
      # -------------------
      # Put all the code above in a generic export-then-execute use case
      # Then you pass in a Key/Value Dictionary
      #
      # { "AWS_ACCESS_KEY_ID" => "@access_key",
      #   "AWS_SECRET_ACCESS_KEY" => "@secret_key",
      #   "AWS_DEFAULT_REGION" => "region_key"
      # }
      #
      # And pass in a command array [ "terraform #{command_name} #{auto_approve}", "terraform graph ..." ]
      #
      # Validation is done by the generic use case (which loops checking that every value exists
      # as a key at the opened location.
      #
      # If all good the generic use case exports the ENV vars and runs each command in the list.
      # PS - configure map in INI not code file
      #
      # The extra power will speed up generation of environment variable use cases including
      # ansible, s3 bucket operations, git interactions and more.
      #
      # ############## | ############################################################
      # ############## | ############################################################

      puts ""
      puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
      puts ""

      ENV[ "AWS_ACCESS_KEY_ID"     ] = chapter_data[ verse_id ][ "@access.key" ]
      ENV[ "AWS_SECRET_ACCESS_KEY" ] = chapter_data[ verse_id ][ "@secret.key" ]
      ENV[ "AWS_DEFAULT_REGION"    ] = chapter_data[ verse_id ][ "region.key"  ]

      mini_dictionary = chapter_data[ verse_id ]
      mini_dictionary.each do | key_str, value_object |

        is_env_var = key_str.start_with?( ENV_VAR_PREFIX_A ) || key_str.start_with?( ENV_VAR_PREFIX_B )
        next unless is_env_var

        env_var_name = key_str[ ENV_VAR_PREFIX_A.length .. -1 ] if key_str.start_with? ENV_VAR_PREFIX_A
        env_var_name = key_str[ ENV_VAR_PREFIX_B.length .. -1 ] if key_str.start_with? ENV_VAR_PREFIX_B
        env_var_keyname = TERRAFORM_EVAR_PREFIX + env_var_name
        ENV[ env_var_keyname ] = value_object
        puts "Environment variable #{env_var_keyname} has been set."

      end

      puts ""
      puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
      puts ""

      auto_approve = @command && @command.eql?( "plan" ) ? "" : "-auto-approve"
      command_name = @command ? @command : "apply"
      system "terraform #{command_name} #{auto_approve}"

      puts ""
      puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
      puts ""

    end


  end


end
