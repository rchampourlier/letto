# frozen_string_literal: true
source 'https://rubygems.org'

ruby '2.3.3'

gem 'bundler'
gem 'hanami',       '~> 0.9'
gem 'hanami-model', '~> 0.7'
gem 'rake'

gem 'httparty'

# Storage
gem 'pg'

# Integrations
gem 'nokogiri'
gem 'oauth'
gem 'ruby-trello'

# Patterns
gem 'dry-struct'
gem 'dry-system'
gem 'event_train', '~> 0.2.1'

group :development do
  # Code reloading
  # See: http://hanamirb.org/guides/projects/code-reloading
  # gem 'shotgun'
  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-shotgun'
  gem 'terminal-notifier-guard'
end

group :test, :development do
  gem 'awesome_print'
  gem 'dotenv', '~> 2.0'
  gem 'pry'
end

group :test do
  gem 'capybara'
  gem 'minitest'
  gem 'minitest-reporters'
end

group :production do
  gem 'puma'
end
