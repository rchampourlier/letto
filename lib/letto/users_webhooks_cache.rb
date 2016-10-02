require "trello_client"
require "data/user_repository"

module Letto
  class UsersWebhooksCache
    def self.load(webhook_url_root: "")
      users = Data::UserRepository.all()
      @user_webhooks_cache = {}
      users.each do |user|
        trello_client = TrelloClient.new(user[:access_token], user[:access_token_secret])
        return nil if trello_client.nil?
        webhooks = trello_client.webhooks
        return nil if webhooks.nil?
        webhooks = webhooks.map(&:attributes) 
        webhooks.each do |webhook|
          callback_url = webhook[:callback_url]
          callback_id = callback_url.gsub(webhook_url_root+"/", '')
          @user_webhooks_cache[callback_id] = user
        end
      end
    end

    def self.trello_client_from_callback(callback_url)
      return nil if callback_url.nil?
      access_token = @user_webhooks_cache[callback_url][:access_token]
      access_token_secret = @user_webhooks_cache[callback_url][:access_token_secret]
      TrelloClient.new(access_token, access_token_secret)
    end 
  end
end
