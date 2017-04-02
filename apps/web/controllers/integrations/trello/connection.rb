# frozen_string_literal: true
module Web::Controllers
  module Integrations
    module Trello

      # Top-module for connection actions
      module Connection

        TRELLO_OAUTH_CONFIG = {
          site: 'https://trello.com',
          request_token_path: '/1/OAuthGetRequestToken',
          authorize_path: '/1/OAuthAuthorizeToken',
          access_token_path: '/1/OAuthGetAccessToken',
          http_method: :get
        }.freeze

        AUTHORIZE_URL_PARAMS = {
          name: ENV['TRELLO_APP_NAME'] || 'Unknown application',
          scope: 'read,write'
        }.freeze

        def self.oauth_consumer
          Letto.dep('oauth_consumer_class').new(
            ENV['TRELLO_CONSUMER_KEY'],
            ENV['TRELLO_CONSUMER_SECRET'],
            TRELLO_OAUTH_CONFIG
          )
        end
      end
    end
  end
end
