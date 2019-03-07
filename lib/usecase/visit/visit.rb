#!/usr/bin/ruby
	
module SafeDb

  class Visit < UseCase

    def execute

      require "watir" 
      require "rspec/expectations" 

      ## see README.md for documentation on installing geckodriver

      @browser ||= Watir::Browser.new :firefox 
      @browser.goto "google.com" 
      @browser.text_field(:name => "q").set "apollo akora"
      @browser.button.click 

      @browser.div(:id => "resultStats").wait_until(&:present?)
      sleep 20
      @browser.close

    end


  end


end
