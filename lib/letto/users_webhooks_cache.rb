# frozen_string_literal: true
require "trello_client"
require "data/user_repository"

module Letto

  # Cache to access users registered webhooks
  class UsersWebhooksCache
    def self.load(webhook_url_root: "")
      users = Data::UserRepository.all
      @user_webhooks_cache = {}
      users.each do |user|
        next if user[:trello_access_token].nil? || user[:trello_access_token_secret].nil?
        trello_client = TrelloClient.new(user[:trello_access_token], user[:trello_access_token_secret])
        begin
          webhooks = trello_client.webhooks
        rescue Trello::Error
          Data::UserRepository.update_by_uuid(user[:uuid], trello_access_token: nil, trello_access_token_secret: nil)
          next
        end
        webhooks = webhooks.map(&:attributes)
        webhooks.each do |webhook|
          callback_url = webhook[:callback_url]
          callback_id = callback_url.gsub("#{webhook_url_root}/", "")
          @user_webhooks_cache[callback_id] = {
            access_token: user[:trello_access_token],
            access_token_secret: user[:atrello_ccess_token_secret]
          }
        end
      end
    end

    def self.add_callback_to_cache(callback_id, access_token, access_token_secret)
      @user_webhooks_cache[callback_id] = {
        access_token: access_token,
        access_token_secret: access_token_secret
      }
    end

    def self.remove_callback_from_cache(callback_id)
      @user_webhooks_cache.delete(callback_id)
    end

    def self.trello_client_from_callback(callback_url)
      return nil if callback_url.nil?
      access_token = @user_webhooks_cache[callback_url][:access_token]
      access_token_secret = @user_webhooks_cache[callback_url][:access_token_secret]
      TrelloClient.new(access_token, access_token_secret)
    end
  end
end
