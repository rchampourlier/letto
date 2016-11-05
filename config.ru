# frozen_string_literal: true
require_relative "./config/boot.rb"
require "letto/web_server"

use Rack::MethodOverride

# Starting the Sinatra webserver
run Letto::WebServer
