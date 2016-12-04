# frozen_string_literal: true
require "workflows/node"

module Letto
  module Workflows

    # A WorkflowNode represents the root node of a workflow. It
    # has specific constraints:
    #   - must have a "condition" node,
    #   - the condition node must evaluate to a boolean value,
    #   - must have an "action" node.
    #
    # TODO: do not force condition to be operation, may be an
    #   expression for always true conditions.
    class WorkflowNode < Node

      ERR_MSG_MISSING_CONDITION = "a workflow node must have a condition node (%s)"
      ERR_MSG_MISSING_ACTION = "a workflow node must have an action node (%s)"
      ERR_MSG_CONDITION_RETURN_VALUE_NOT_BOOLEAN = "a condition must return a boolean value (%s)"
      ERR_MSG_CONDITION_NOT_OPERATION = "a condition must be an operation node (%s)"
      ERR_MSG_ACTION_NOT_OPERATION = "an action must be an operation node (%s)"

      def check!
        ensure_condition_present!
        ensure_action_present!
        ensure_action_is_operation!
      end

      def condition_true?(context:)
        condition_node = Node.build(data: data["condition"])
        result = condition_node.evaluate(context: context)
        ensure_condition_result_is_boolean!(result)
        result == true
      end

      # The evaluation of a workflow node is the evaluation of
      # its "action" node.
      def evaluate(context:)
        action_node = Node.build(data: data["action"])
        action_node.evaluate(context: context)
      end

      private

      def ensure_condition_present!
        return unless data["condition"].nil?
        raise Error, format(ERR_MSG_MISSING_CONDITION, data)
      end

      def ensure_condition_result_is_boolean!(result)
        return if result.is_a?(TrueClass) || result.is_a?(FalseClass)
        raise Error, format(ERR_MSG_CONDITION_RETURN_VALUE_NOT_BOOLEAN, data)
      end

      def ensure_action_present!
        return unless data["action"].nil?
        raise Error, format(ERR_MSG_MISSING_ACTION, data)
      end

      def ensure_action_is_operation!
        return if data["action"]["type"] == "operation"
        raise Error, format(ERR_MSG_ACTION_NOT_OPERATION, data)
      end
    end
  end
end
