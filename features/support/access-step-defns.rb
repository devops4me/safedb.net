require 'aruba/cucumber'
require "cli"

When(/^I create book "(.*?)" with password "(.*?)"$/) do |book_name, book_password|
  CLI.start([ "init", book_name, "--password=#{book_password}" ] )
end

When(/^I login to book "(.*?)" with password "(.*?)"$/) do |book_name, book_password|
  CLI.start([ "login", book_name, "--password=#{book_password}" ] )
end

When(/^I should be logged in to book "(.*?)"$/) do |book_name|

  unless SafeDb::StateInspect.is_logged_in?(book_name)
    error_message = "Expected to be logged into book #{book_name}."
    raise RuntimeError, error_message
  end

end
