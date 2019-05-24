#!/usr/bin/ruby
# coding: utf-8

module SafeDb

  # The Github class uses the REST API to talk to Github and create, query,
  # change and delete assets within a specified hosted git repository.
  class Github

    # Initialize a Github repository given the parameter name.
    # the parameter JSON string.
    #
    # @param repository_name [String] name of the Github repository
    #
    def initialize( repository_name )

      data_db = DataStore.new()
      data_db.merge!( JSON.parse( db_json_string ) )
      return data_db

    end


  end


end
