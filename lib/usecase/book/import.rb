#!/usr/bin/ruby
	
module SafeDb

  # The <b>import use case</b> takes a filepath parameter in order to pull in
  # a <em>json</em> formatted data structure. It then proceeds to merge each
  # chapter of the source JSON structure into the corresponding chapter of
  # the destination, handling duplicate key/value pairs in a sensible way.
  #
  class Import < UseCase

    attr_writer :import_filepath

    # The <b>import use case</b> takes a filepath parameter in order to pull in
    # a <em>json</em> formatted data structure. It then proceeds to merge each
    # chapter of the source JSON structure into the corresponding chapter of
    # the destination, handling duplicate key/value pairs in a sensible way.
    def execute

puts "Please engage and implement import use case. File #{@import_filepath}"

    end


  end


end
