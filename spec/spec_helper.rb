# frozen_string_literal: true
require "rspec"
require "webmock/rspec"
require "rack/test"
require "pry"

ENV["RACK_ENV"] = "test"

# Running locally, setup simplecov
require "simplecov"
SimpleCov.start do
  add_filter do |src|
    # Ignoring files from the spec directory
    src.filename =~ %r{/spec/}
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
