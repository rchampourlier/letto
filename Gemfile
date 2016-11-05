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

# Integrations
gem "oauth"
gem "slack-ruby-bot"
gem "ruby-trello"
gem "nokogiri"

# Ruby sugar
gem "activesupport"

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
  gem "coveralls", require: false
  gem "simplecov", require: false
  gem "timecop"
  gem "sinatra-sessionography"
end
