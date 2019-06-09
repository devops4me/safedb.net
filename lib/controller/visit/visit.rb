#!/usr/bin/ruby
	
module SafeDb

  class Visit < Controller

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


=begin

 install python3 and pip3
 pip3 install selinium
 then place the below code in a file and run with python <<file-name.py>>
 note that a logfile called "geckodriver.log" will be created

 -------------------------------------------
#!/usr/bin/env python

from selenium import webdriver
from selenium.webdriver.common.keys import Keys

import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys

browser = webdriver.Firefox()
browser.get('http://www.google.co.uk')

search = browser.find_element_by_name('q')
search.send_keys("sainsburys")
search.send_keys(Keys.RETURN)
time.sleep(20)
browser.quit()


=end
