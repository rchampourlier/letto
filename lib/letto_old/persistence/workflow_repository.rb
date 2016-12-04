# frozen_string_literal: true
require "persistence/repository"
module Letto
  module Persistence

    # Handle workflows data
    class WorkflowRepository < Repository

      def self.create(user_uuid:, data:)
        uuid = generate_uuid
        insert(
          uuid: uuid,
          user_uuid: user_uuid,
          data: data
        )
        uuid
      end

      def self.for_user_uuid(user_uuid)
        return nil if user_uuid.nil?
        where(user_uuid: user_uuid.to_s)
      end

      def self.for_uuid(uuid)
        return nil if uuid.nil?
        first_where(uuid: uuid.to_s)
      end

      def self.update_by_uuid(uuid:, data:)
        values = { data: data }.reject { |_, v| v.nil? }
        update_where({ uuid: uuid.to_s }, values)
      end

      def self.delete_by_uuid(uuid:)
        delete(uuid: uuid.to_s)
      end
    end
  end
end
