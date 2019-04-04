#!/usr/bin/ruby
# coding: utf-8


# To use this inspector copy and paste this code into any class at any position.


# It will print out
#
# - the global variables
# - the class constants
# - the loaded features
# - the local variables
# - the last exception
# - the command line variables
#
# This is extremely handly for troubleshooting


=begin

      puts ""
      puts "QQQ QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ"
      puts "QQQ ~~~~~~~~~~~~~ Global Variable Array List ~~~~~~~~~~~~~~~~ QQQQQ"
      puts "QQQ QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ"

      puts global_variables().inspect

      puts "QQQ QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ"
      puts "QQQ ~~~~~~~~~~~~~ Global Variable Values Printed ~~~~~~~~~~~~~~~~ QQQQQ"
      puts "QQQ QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ"

      global_variables().sort.each do |name|

        puts "<<< ------------------------------------------------------------------->>>"
        puts "<<< #{name.to_s} >>>"
        puts "<<< ------------------------------------------------------------------->>>"
        next if name.to_s.eql?( "$FILENAME" )
        global_variable_value = eval "#{name}.inspect"
        puts "<<< #{global_variable_value}"

      end

      puts ""
      puts "QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ"
      puts "QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ"
      puts ""
      puts "QQQQQQQQQQQ QQQQQQQQQQ QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ"
      puts "QQQQQQQQQQQ Bug Finder QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ"
      puts "QQQQQQQQQQQ QQQQQQQQQQ QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ"
      puts ""
      self.instance_variables().map do |attribute|
        puts "=============================================="
        puts "----------------------------------------------"
        puts attribute
        pp self.instance_variable_get(attribute)
      end
      puts "=============================================="
      puts "QQQQQQQQQQQ QQQQQQQQQQ QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ"
      puts "QQQQQQQQQQQ QQQQQQQQQQ QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ"
      puts ""
      puts "### ------------------------------------"
      puts "### Inspect View"
      puts "### ------------------------------------"
      pp self.inspect
      puts "### ------------------------------------"
      puts "QQQQQQQQQQQ QQQQQQQQQQQQQQQ QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ"
      puts "QQQQQQQQQQQ Local Variables QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ"
      puts "QQQQQQQQQQQ QQQQQQQQQQQQQQQ QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ"

      local_variables().map do |attribute|
        puts "=============================================="
        puts "----------------------------------------------"
        puts attribute
        pp binding().local_variable_get(attribute.to_sym)
      end
      puts "QQQQQQQQQQQ QQQQQQQQQQQQQQQ QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ"

      puts ""

=end
