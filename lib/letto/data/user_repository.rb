# frozen_string_literal: true
require "data/repository"
module Letto
  module Data

    # Handle users data
    class UserRepository < Repository

      def self.create(username, access_token, access_token_secret, session_id)
        db[:users].insert(
          row(
            uuid: generate_uuid,
            username: username,
            access_token: access_token,
            access_token_secret: access_token_secret,
            session_id: session_id
          )
        )
      end

      def self.for_session_id(session_id)
        return nil if session_id.nil?
        user = db[:users].where("session_id = \'#{session_id}\'").first
        user
      end
    end
  end
end
