#!/usr/bin/ruby
	
module SafeDb

  # This vpn use case sets up vpn connection paraphernelia and can bring up a VPN connection
  # and then tear it down.
  #
  #     safe vpn up
  #     safe vpn down
  class Vpn < UseCase

    attr_writer :command

    def execute

      if( @command && @command.eql?( "down" ) )

        puts ""
        system @dictionary[ :nm_conn_off ]; sleep 2;
        system @dictionary[ :nm_conn_del ]
        puts ""
        return

      end

      puts ""
      system @dictionary[ :safe_write_cmd ]
      puts "[#{@dictionary[ :vpn_filename ]}] temporarily exported to [#{@dictionary[ :vpn_filepath ]}]."
      system @dictionary[ :nm_import_cmd  ]
      File.delete( @dictionary[ :vpn_filepath ] )
      puts "Exported file [#{@dictionary[ :vpn_filepath ]}] has now been deleted."

      system @dictionary[ :nm_default_cmd ]
      system @dictionary[ :nm_user_cmd    ]
      system @dictionary[ :nm_reload_cmd  ]
      system @dictionary[ :nm_flags_cmd   ]
      system @dictionary[ :chown_cmd_1    ]

      vpn_data = IniFile.load( @dictionary[:nm_filepath] )
      vpn_data['vpn-secrets'] = { 'password' => @dictionary[:vpn_password] }
      vpn_data.write()

      system @dictionary[ :chown_cmd_2 ]
      system @dictionary[ :nm_restart  ]; sleep 2;
      system @dictionary[ :nm_conn_up  ]
      puts ""

    end


  end


end
