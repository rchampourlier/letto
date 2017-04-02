# frozen_string_literal: true
require "integrations/trello/authentication"
require "integrations/trello/boards"
require "integrations/trello/client"
require "integrations/trello/webhooks"

module Letto
  module Integrations

    # Top-level module for Trello integration.
    #
    # This module may be used to register all necessary sub-modules
    # into the Sinatra application using `register Letto::Integrations::Trello`.`
    # It will perform the registration of all necessary submodules.
    module Trello
      def self.perform_api_call(user_uuid:, verb:, path:, payload:)
        raise "Not implemented"
      end

      # Returns a Trello client instance for the specified user
      def self.client(user:)
        trello_access_token = user[:trello_access_token]
        trello_access_token_secret = user[:trello_access_token_secret]
        if trello_access_token.nil? || trello_access_token_secret.nil?
          raise "No trello_access_token for user with id `#{user[:id]}`"
        end
        Client.new(trello_access_token, trello_access_token_secret)
      end

      def self.registered(app)
        app.namespace "/trello" do |namespace|
          namespace.register Authentication.routes
          namespace.register Boards.routes
          namespace.register Webhooks.routes
        end
      end
    end
  end
end
