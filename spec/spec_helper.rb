# frozen_string_literal: true
require "rspec"
require "webmock/rspec"
require "rack/test"
require "capybara/rspec"

ENV["RACK_ENV"] = "test"

# Running locally, setup simplecov
require "simplecov"
SimpleCov.start do
  add_filter do |src|
    src.filename =~ %r{/spec/}
    src.filename =~ %r{/config/boot.rb}
  end
end

require File.expand_path("../../config/boot", __FILE__)

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require(f) }

RSpec.configure do |config|
  config.order = :random
  config.include Rack::Test::Methods
  config.include Capybara::DSL
  config.include SpecHelpers::Features
  config.include SpecHelpers::Fixtures
end

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, headers: { "HTTP_USER_AGENT" => "Capybara" })
end

require "letto/web_interface"
require "sinatra/sessionography"
Capybara.app = Letto::WebInterface
Letto::WebInterface.helpers Sinatra::Sessionography

# If the database is necessary during the tests, you may uncomment
# the following lines.
require "sequel"
Sequel.extension :migration, :core_extensions

require "persistence/user_repository"
require "persistence/workflow_repository"

MIGRATIONS_DIR = File.expand_path("../../config/db_migrations", __FILE__)
client = Letto::Persistence.db
RSpec.configure do |config|

  config.before(:all) do
    Sequel::Migrator.apply(client, MIGRATIONS_DIR)
  end

  config.after(:all) do
    Sequel::Migrator.apply(client, MIGRATIONS_DIR, 0)
  end
end
