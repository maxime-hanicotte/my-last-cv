require "bundler/setup"
require "my_last_cv"
require "rspec"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.formatter = :documentation
end