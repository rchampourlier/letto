# frozen_string_literal: true
require "data/repository"
module Letto
  module Data

    # Handle workflows data
    class WorkflowRepository < Repository

      def self.create(content)
        uuid = generate_uuid
        insert(
          uuid: uuid,
          content: content
        )
        uuid
      end

      def self.for_uuid(uuid)
        return nil if uuid.nil?
        first_where(uuid: uuid.to_s)
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
