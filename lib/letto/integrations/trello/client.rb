# frozen_string_literal: true
require "trello"

module Letto
  module Integrations
    module Trello

      # Client to perform actions through Trello API
      class Client
        attr_reader :client

        def initialize(access_token, access_token_secret)
          @client = ::Trello::Client.new(
            consumer_key: ENV["TRELLO_CONSUMER_KEY"],
            consumer_secret: ENV["TRELLO_CONSUMER_SECRET"],
            oauth_token: access_token,
            oauth_token_secret: access_token_secret
          )
        end

        def username
          member.username
        end

        def organizations
          find_many(
            ::Trello::Organization,
            "/members/me/organizations"
          )
        end

        def boards
          find_many(
            ::Trello::Board,
            "/members/me/boards"
          )
        end

        def webhooks
          find_many(
            ::Trello::Webhook,
            "/tokens/#{oauth_token}/webhooks"
          )
        end

        def api_call(verb, target, payload)
          body = payload ? payload : {}
          send(:"#{verb.downcase}", target, body)
        end

        # @return [String] Trello create webhook's id
        def create_board_webhook(board_id, callback_url, description)
          webhook_id = SecureRandom.uuid
          create(
            :webhook,
            "description" => description,
            "idModel" => board_id,
            "callbackURL" => [callback_url, webhook_id].join("/")
          )
          webhook_id
        end

        def delete_webhook(webhook_id)
          delete("/webhooks/#{webhook_id}")
        end

        def delete_token(token_id)
          delete("/tokens/#{token_id}")
        end

        private

        def member
          @member ||= find(:members, "me")
        end

        def method_missing(name, *args)
          client.send(name, *args)
        end
      end
    end
  end
end
