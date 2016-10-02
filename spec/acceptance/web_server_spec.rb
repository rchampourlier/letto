# frozen_string_literal: true
require "spec_helper"
require "rack/test"

# Monkey-patching UsersWebhookCache to prevent
# tests from failing by trying to perform an
# API call to Trello.
require "users_webhooks_cache"
module Letto
  class UsersWebhooksCache
    def self.load(_options)
    end
  end
end

require "letto/web_server"

describe "Letto::WebServer" do
end
