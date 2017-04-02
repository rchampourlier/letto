# frozen_string_literal: true
require "persistence/repository"
module Letto
  module Persistence

    # Handle workflows data
    class WorkflowRepository < Repository

      def self.create(user_uuid:, data:)
        id = generate_uuid
        insert(
          id: id,
          user_uuid: user_uuid,
          data: data
        )
        id
      end

      def self.for_user_uuid(user_uuid)
        return nil if user_uuid.nil?
        where(user_uuid: user_uuid.to_s)
      end

      def self.for_id(id)
        return nil if id.nil?
        first_where(id: id.to_s)
      end

      def self.update_by_id(id:, data:)
        values = { data: data }.reject { |_, v| v.nil? }
        update_where({ id: id.to_s }, values)
      end

      def self.delete_by_id(id:)
        delete(id: id.to_s)
      end
    end
  end
end
