# frozen_string_literal: true
require "persistence/repository"
module Letto
  module Persistence

    # Handle users data
    class UserRepository < Repository

      def self.create(username:, trello_access_token:, trello_access_token_secret:, session_id:)
        insert(
          uuid: generate_uuid,
          username: username,
          trello_access_token: trello_access_token,
          trello_access_token_secret: trello_access_token_secret,
          session_id: session_id
        )
      end

      def self.for_session_id(session_id)
        return nil if session_id.nil?
        user = first_where(session_id: session_id.to_s)
        user
      end

      def self.update_by_uuid(uuid:, trello_access_token: nil, trello_access_token_secret: nil, force_nil: false)
        values = {
          trello_access_token: trello_access_token,
          trello_access_token_secret: trello_access_token_secret
        }
        values.reject! { |_, v| v.nil? } unless force_nil
        update_where({ uuid: uuid.to_s }, values)
      end

      def self.delete_by_uuid(uuid:)
        delete(uuid: uuid.to_s)
      end
    end
  end
end
