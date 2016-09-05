require "rspec"
require "webmock/rspec"
require "rack/test"
require "pry"

ENV["RACK_ENV"] = "test"

if ENV["CI"]
  # Running on CI, setup Coveralls
  require "coveralls"
  Coveralls.wear!
else
  # Running locally, setup simplecov
  require "simplecov"
  # require "simplecov-lcov"
  # SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
  # require "simplecov-json"
  # SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
  SimpleCov.start do
    add_filter do |src|
      # Ignoring files from the spec directory
      src.filename =~ %r{/spec/}
    end
  end
end

# Setup app-specific environment variables
test_environment = {
}
test_environment.each { |k, v| ENV[k] = v }

require File.expand_path("../../config/boot", __FILE__)
Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require(f) }


RSpec.configure do |config|
  config.after(:each) do
  end
end
