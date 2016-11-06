# frozen_string_literal: true
require "trello_client"
require "data/user_repository"

module Letto

  # Cache to access users registered webhooks
  #
  # Fetches all Trello webhooks through the API for each user in the
  # database with valid OAuth tokens.
  #
  # If the OAuth tokens are not valid, they are removed from the database.
  #
  # This cache enables identifying the user from a webhook's ID so that
  # we can perform Trello API calls on its behalf by using its OAuth
  # tokens.
  class UsersWebhooksCache

    # The cache is stored in the @value instance variable.
    # It's an hash with callback ids as keys.
    attr_reader :value

    # Loads the webhooks for every user in the database, using
    # the Trello API.
    def fetch(webhook_url_root: "")
      @value = {}
      Data::UserRepository.all.each do |user|
        next unless trello_tokens_for_user?(user)
        add_webhooks_for_user(user, webhook_url_root)
      end
    end

    def add_webhooks_for_user(user, webhook_url_root)
      webhooks = fetch_webhooks_for_user(user)
      webhooks.each do |webhook|
        add_webhook_to_cache(user, webhook, webhook_url_root)
      end
    rescue Trello::Error
      remove_access_token_for_user(user)
    end

    def remove_access_token_for_user(user)
      Data::UserRepository.update_by_uuid(
        user[:uuid],
        trello_access_token: nil,
        trello_access_token_secret: nil
      )
    end

    def remove_callback_from_cache(callback_id)
      value.delete(callback_id)
    end

    def user_uuid_from_callback(callback_id)
      return nil if value[callback_id].nil?
      value[callback_id][:uuid]
    end

    def trello_client_from_callback(callback_id)
      return nil if callback_id.nil?
      access_token = value[callback_id][:access_token]
      access_token_secret = value[callback_id][:access_token_secret]
      trello_client(access_token, access_token_secret)
    end

    def trello_client(access_token, access_token_secret)
      TrelloClient.new(access_token, access_token_secret)
    end

    def add_webhook_to_cache(user, webhook, webhook_url_root)
      callback_url = webhook.attributes[:callback_url]
      callback_id = callback_url.gsub("#{webhook_url_root}/", "")
      value[callback_id] = {
        uuid: user[:uuid],
        access_token: user[:trello_access_token],
        access_token_secret: user[:trello_access_token_secret]
      }
    end

    def fetch_webhooks_for_user(user)
      client = trello_client(user[:trello_access_token], user[:trello_access_token_secret])
      client.webhooks
    end

    def trello_tokens_for_user?(user)
      user[:trello_access_token].present? && user[:trello_access_token_secret].present?
    end
  end
end
