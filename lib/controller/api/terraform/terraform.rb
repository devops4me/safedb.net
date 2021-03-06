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
  class Terraform < EditVerse

    attr_writer :command, :debug

    # This prefix is tagged onto environment variables which Terraform will read
    # and convert for consumption into module input variables.
    TERRAFORM_EVAR_PREFIX = "TF_VAR_"

    # Prefix for environment variable key (line). Before safe runs the
    # <tt>terraform apply</tt> command, it examines the lines at the opened
    # chapter and verse and any that start with this prefix will be substringed
    # to create an environment variable with the substringed name and key value.
    ENV_VAR_PREFIX_A = "tfvar."

    # Secure var prefix for environment variable key (line). Before safe runs the
    # <tt>terraform apply</tt> command, it examines the lines at the opened
    # chapter and verse and any that start with this prefix will be substringed
    # to create an environment variable with the substringed name and key value.
    ENV_VAR_PREFIX_B = "@#{ENV_VAR_PREFIX_A}"

    TIMESTAMP_LINE_KEY = "tfvar.in_timestamp"
    DESCRIBES_LINE_KEY = "tfvar.in_description"


    def edit_verse()

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

      command_name = @command ? @command : "apply"
      is_apply = command_name.eql?( "apply" ) 
      is_blast = command_name.eql?( "destroy" ) 

      has_timestamp = @verse.has_key?( TIMESTAMP_LINE_KEY )
      is_create_stamps = is_apply && !has_timestamp
      is_remove_stamps = is_blast && has_timestamp

      the_description = "was created on #{TimeStamp.readable()}."

      @verse.store( TIMESTAMP_LINE_KEY, TimeStamp.yjjjhhmmsst() ) if is_create_stamps
      @verse.store( DESCRIBES_LINE_KEY, the_description )       if is_create_stamps

      ENV[ "AWS_ACCESS_KEY_ID"     ] = @verse[ "@access.key" ]
      ENV[ "AWS_SECRET_ACCESS_KEY" ] = @verse[ "@secret.key" ]
      ENV[ "AWS_DEFAULT_REGION"    ] = @verse[ "region.key"  ]

      ENV[ "TF_LOG" ] = "DEBUG" if @debug == true

      @verse.each do | key_str, value_object |

        is_env_var = key_str.start_with?( ENV_VAR_PREFIX_A ) || key_str.start_with?( ENV_VAR_PREFIX_B )
        next unless is_env_var

        env_var_name = key_str[ ENV_VAR_PREFIX_A.length .. -1 ] if key_str.start_with? ENV_VAR_PREFIX_A
        env_var_name = key_str[ ENV_VAR_PREFIX_B.length .. -1 ] if key_str.start_with? ENV_VAR_PREFIX_B
        env_var_keyname = TERRAFORM_EVAR_PREFIX + env_var_name
        ENV[ env_var_keyname ] = value_object
        puts "Environment variable #{env_var_keyname} has been set."
        log.info(x) { "Setting terraform environment variable => #{env_var_keyname}" }

      end

      puts ""
      puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
      puts ""

      auto_approve = @command && @command.eql?( "plan" ) ? "" : "-auto-approve"
      exit_success = system "terraform #{command_name} #{auto_approve}"

      puts ""
      puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
      puts ""

      return if ( exit_success.nil?() || !exit_success )

      @verse.delete( TIMESTAMP_LINE_KEY ) if is_remove_stamps
      @verse.delete( DESCRIBES_LINE_KEY ) if is_remove_stamps

      return unless is_apply

      puts "Successful terraform apply."
      graph_filename = "network-#{@book.get_open_verse_name()}-#{TimeStamp.yyjjj_hhmm_sst()}.png"
      system "terraform graph | dot -Tpng > #{graph_filename}"
      puts "Resource graph #{graph_filename} created."
      puts ""

    end


  end


end
