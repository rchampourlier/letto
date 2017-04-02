# frozen_string_literal: true
require 'persistence/repository'
module Letto
  module Persistence

    # Handle users data
    class UserRepository < Repository

      def self.create(username:, trello_access_token:, trello_access_token_secret:, session_id:)
        insert(
          id: generate_id,
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


      def self.delete_by_id(id:)
        delete(id: id.to_s)
      end
    end
  end
end
