# frozen_string_literal: true

# Load dependencies
require "rubygems"
require "bundler"

env = (ENV["RACK_ENV"] ||= "development")
Bundler.setup(:default, env.to_sym)

if env == "development"
  require "dotenv"
  require "pry"
  Dotenv.load
end

root_dir = File.expand_path "../..", __FILE__

$LOAD_PATH.unshift root_dir
$LOAD_PATH.unshift File.join(root_dir, "lib")
$LOAD_PATH.unshift File.join(root_dir, "lib", "letto")

require "letto"
