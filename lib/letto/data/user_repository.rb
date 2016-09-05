# frozen_string_literal: true
require "data/db"
module Letto
  module Data

    # Handle users data
    class UserRepository

      def self.create(username, access_token, access_token_secret, session_id)
        time = Time.now
        row = {
          uuid: generate_uuid,
          username: username,
          access_token: access_token,
          access_token_secret: access_token_secret,
          session_id: session_id,
          created_at: time,
          updated_at: time
        }
        Db::CLIENT[:users].insert(row)
      end

      def self.for_session_id(session_id)
        return nil if session_id.nil?
        user = Db::CLIENT[:users].where("session_id = \'#{session_id}\'").first
        user
      end

      def self.generate_uuid
        SecureRandom.uuid
      end
    end
  end
end
