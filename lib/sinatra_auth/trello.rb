# frozen_string_literal: true
require "oauth"
require "oauth/consumer"
module SinatraAuth
  class Trello

    def self.consumer(consumer_key, consumer_secret, name)
      @consumer ||= OAuth::Consumer.new(
        consumer_key,
        consumer_secret,
        site: "https://trello.com",
        request_token_path: "/1/OAuthGetRequestToken",
        authorize_path: "/1/OAuthAuthorizeToken",
        access_token_path: "/1/OAuthGetAccessToken",
        http_method: :get,
        name: name
      )
    end
  end
end
