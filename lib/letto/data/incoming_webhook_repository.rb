# frozen_string_literal: true
require "data/repository"
module Letto
  module Data

    # Handle users data
    class IncomingWebhookRepository < Repository

      def self.create(description, remote_id = nil)
        insert(
          uuid: generate_uuid,
          description: description,
          remote_id: remote_id
        )
      end
    end
  end
end
