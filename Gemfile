# frozen_string_literal: true
source "https://rubygems.org"

ruby "2.3.1"

gem "httparty"
gem "sinatra"
gem "sinatra-contrib"
gem "puma"

# Sinatra extensions
gem "sinatra-flash"

# For the console
gem "pry"
gem "awesome_print"
gem "ruby-progressbar"

# Storage
gem "pg"
gem "sequel"
gem "sequel_pg"

# Integrationss
gem "oauth"
gem "ruby-trello"
gem "nokogiri"

# Ruby sugar
gem "activesupport"

# Patterns
gem "event_train", "~> 0.2.1"

group :development do
  gem "guard"
  gem "guard-rspec", require: false
  gem "guard-shotgun"
  gem "terminal-notifier-guard"
end

group :development, :test do
  gem "rake"
  gem "dotenv"
end

group :test do
  gem "rack-test"
  gem "rspec"
  gem "webmock"
  gem "simplecov", require: false
  gem "codeclimate-test-reporter", "~> 1.0.0"
  gem "timecop"
  gem "sinatra-sessionography"
  gem "capybara"
end
