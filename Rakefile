require "bundler/gem_tasks"
require "rake/testtask"

# -
# - This configuration allows us to run "rake test"
# - and invoke minitest to execute all files in the
# - test directory with names ending in "_test.rb".
# -
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => :test

require 'yard'
# This configuration allows us to run "rake yard"
# to build documentation.
YARD::Rake::YardocTask.new do |t|
 t.files   = ['lib/**/*.rb']   # optional
 t.stats_options = ['--list-undoc']
end
