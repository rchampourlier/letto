# frozen_string_literal: true
module Workflows

  # Selects the workflows for the specified context.
  class Selection
    attr_reader :user_uuid, :context

    def initialize(user_uuid:, context: nil)
      @user_uuid = user_uuid
      @context = context
    end

    def matching_workflows(webhook)
      filter_workflows_on_conditions(workflows, webhook)
    end

    def execute_action(action, webhook)
      evaluation_node(action, webhook.parsed_body, webhook.id)
    end

    def filter_workflows_on_conditions(workflows, webhook)
      workflows.select { |w| verifies_workflow_conditions(w, webhook) }
    end

    def verifies_workflow_conditions(workflow, webhook)
      workflow['conditions'].each do |condition|
        return false unless verify_workflow_expected_values(condition, webhook)
      end
      true
    end

    def verify_workflow_expected_values(condition, webhook)
      type = condition['type']
      expected_values = condition['value']
      path = condition['path']
      return verify_workflow_condition(type, expected_values, path, webhook) unless expected_values.is_a?(Array)
      expected_values.each do |expected_value|
        return true if verify_workflow_condition(type, expected_value, path, webhook)
      end
      false
    end

    def verify_workflow_condition(type, expected_value, path, webhook)
      if type == 'string_comparison'
        observed_value = webhook.parsed_body.dig(*path.split('.'))
        return expected_value == observed_value
      elsif type == 'regex_comparison'
        observed_value = webhook.parsed_body.dig(*path.split('.'))
        return observed_value.match(expected_value)
      end
      raise "Unknown condition type: #{condition['type']}"
    end
  end
end
