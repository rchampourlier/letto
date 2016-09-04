# frozen_string_literal: true
require "data/db"
module Letto
  module Data

    # Handle users data
    class UserRepository
      def create_user(uuid)
        time = Time.now
        row = { uuid: uuid, created_at: time, updated_at: time }
        Data::Db::CLIENT.insert(row)
      end

      def self.find_user(uuid)
        return nil if uuid.nil?
        user = Data::Db::CLIENT[:users].where("uuid = \'#{uuid}\'").first
        user
      end
    end
  end
end
