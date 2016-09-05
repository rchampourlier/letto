# frozen_string_literal: true
require "trello"

module Letto

  # Client to perform actions through Trello API
  class TrelloClient
    attr_reader :client

    def self.for_user(user_row)
      new(user_row[:access_token], user_row[:access_token_secret])
    end

    def initialize(access_token, access_token_secret)
      @client = Trello::Client.new(
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
      client.find_many(
        Trello::Organization,
        "/members/me/organizations"
      )
    end

    def boards
      client.find_many(
        Trello::Board,
        "/members/me/boards"
      )
    end

    def webhooks
      client.find_many(
        Trello::Webhook,
        "/tokens/#{token}/webhooks"
      )
    end

    def create_webhook(model_id, callback_url)
      webhook_id = SecureRandom.uuid
      trello_webhook = client.create(
        :webhook,
        "description" => "webhook on board #{model_id}",
        "idModel" => model_id,
        "callbackURL" => [callback_url, webhook_id].join("/")
      )
      trello_webhook_id = trello_webhook.attributes[:id]
      puts(webhook_id)
      puts(trello_webhook_id)
    end

    def delete_webhook(webhook_id)
      client.delete("/webhooks/#{webhook_id}")
    end

    private

    def token
      client.oauth_token
    end

    def member
      @member ||= @client.find(:members, "me")
    end

    def method_missing(name, *args)
      @client.send(name, *args)
    end
  end
end
