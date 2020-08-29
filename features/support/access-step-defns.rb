require 'aruba/cucumber'
require "cli"

When(/^I create book "(.*?)" with password "(.*?)"$/) do |book_name, book_password|
  CLI.start([ "init", book_name, "--password=#{book_password}" ] )
end

When(/^I login to book "(.*?)" with password "(.*?)"$/) do |book_name, book_password|
  CLI.start([ "login", book_name, "--password=#{book_password}" ] )
end

When(/^I view the book$/) do
  CLI.start([ "view" ] )
end
