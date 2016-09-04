# frozen_string_literal: true

# Load dependencies
require "rubygems"
require "bundler"
require "pry" # temp

env = (ENV["APP_ENV"] ||= "development")
Bundler.setup(:default, env.to_sym)

if env == "development"
  require "dotenv"
  Dotenv.load
end

root_dir = File.expand_path "../..", __FILE__

$LOAD_PATH.unshift root_dir
$LOAD_PATH.unshift File.join(root_dir, "lib")
$LOAD_PATH.unshift File.join(root_dir, "lib", "letto")

require "letto"
