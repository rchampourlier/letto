# frozen_string_literal: true
require "data/repository"
module Letto
  module Data

    # Handle users data
    class UserRepository < Repository

      def self.create(username, access_token, access_token_secret, session_id)
        insert(
          uuid: generate_uuid,
          username: username,
          trello_access_token: access_token,
          trello_access_token_secret: access_token_secret,
          session_id: session_id
        )
      end

      def self.for_session_id(session_id)
        return nil if session_id.nil?
        user = first_where(session_id: session_id.to_s)
        user
      end

      def self.update_by_uuid(uuid, values)
        update_where({ uuid: uuid.to_s }, values)
      end

      def self.delete_by_uuid(uuid)
        delete(uuid: uuid.to_s)
      end
    end
  end
end
