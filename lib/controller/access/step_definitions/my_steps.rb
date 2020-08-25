require 'cucumber'

module SafeDb

  config = Cucumber::Configuration.new
=begin
  When(/^I create a new book$/) do
    init_uc = SafeDb::Init.new
    init_uc.password = "abcde12345"
    init_uc.book_name = "turkey"
    init_uc.flow()
  end
=end

end
