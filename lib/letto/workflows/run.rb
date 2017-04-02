# frozen_string_literal: true
module Letto
  module Workflows

    # Runs a given workflow.
    class Run
      attr_reader :user_uuid

      def initialize(user_uuid:)
        @user_uuid = user_uuid
      end

      def perform(workflow:, context:)
        node = Node.build(data: workflow)
        node.evaluate(
          user_uuid: user_uuid,
          context: context
        )
      end
    end
  end
end
