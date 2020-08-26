require 'aruba/cucumber'
require "controller/abstract/controller"
require "controller/abstract/authenticate"
require "controller/access/init"
require "utils/identity/identifier"
require "model/indices"
require "utils/keys/key"
require "utils/keys/key.64"
require "utils/extend/string"
require "utils/store/datamap"
require "utils/key.error"
require "model/state_evolve"
require "model/file_tree"
require "utils/logs/logger"
require "utils/time/timestamp"
require "utils/store/datastore"
require "version"
require "model/content"
require "utils/keys/random.iv"
require "model/text_chunk"
require 'openssl'
require "base64"
require "utils/kdfs/kdf.api"
require "utils/kdfs/bcrypt"
require "utils/kdfs/pbkdf2"
require "utils/git/gitflow"

include LogImpl

When(/^I create a new book$/) do
  init_uc = SafeDb::Init.new
  init_uc.password = "abcde12345"
  init_uc.book_name = "turkeyY"
  init_uc.flow()
end
