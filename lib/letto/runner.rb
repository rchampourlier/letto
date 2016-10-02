# frozen_string_literal: true
module Letto

  # The runner
  class Runner
    attr_reader :config
    SUPPORTED_NODE_TYPES = %w(expression operation value target payload).freeze
    SUPPORTED_FUNCTION_NAMES = %w(add api_call map min).freeze

    def initialize(config)
      @config = config
    end

    def handle_webhook(webhook)
      matching_workflows(webhook).each do |workflow|
        execute_action(workflow["action"], webhook)
      end
    end

    def matching_workflows(webhook)
      matching_workflows = filter_workflows_on_webhook_id(workflows, webhook.id)
      filter_workflows_on_conditions(matching_workflows, webhook)
    end

    def execute_action(action, webhook)
      evaluate_node(action, webhook.parsed_body)
    end

    private

    def filter_workflows_on_webhook_id(workflows, webhook_id)
      workflows.select do |workflow|
        workflow["webhook_id"] == webhook_id
      end
    end

    def filter_workflows_on_conditions(workflows, webhook)
      workflows.select { |w| verifies_workflow_conditions(w, webhook) }
    end

    def verifies_workflow_conditions(workflow, webhook)
      workflow["conditions"].each do |condition|
        return false unless verify_workflow_condition(condition, webhook)
      end
      true
    end

    def verify_workflow_condition(condition, webhook)
      if condition["type"] == "string_comparison"
        expected_value = condition["value"]
        observed_value = webhook.parsed_body.dig(*condition["path"].split("."))
        return expected_value == observed_value
      end
      raise "Unknown condition type: #{condition['type']}"
    end

    def verify_supported_node_type!(node_type)
      return if SUPPORTED_NODE_TYPES.include?(node_type)
      raise "Unknown node type: #{node_type}"
    end

    def verify_supported_function!(function_name)
      return if SUPPORTED_FUNCTION_NAMES.includes?(function_name)
      raise "Unknown function name: #{function_name}"
    end

    def evaluate_target(node, data)
      raw_target = node["value"]
      re = /{{(.*)}}/
      expression = raw_target[re, 1].strip
      evaluated_expression = evaluate_expression({ "value" => expression }, data)
      raw_target.gsub(re, evaluated_expression)
    end

    def evaluate_payload(node, data)
      payload = node["value"]
      payload.each_with_object({}) do |(argument, node), evaluated_args|
        evaluated_args[argument] = evaluate_node(node, data)
      end
    end

    def evaluate_node(node, data)
      node_type = node["type"]
      verify_supported_node_type!(node_type)
      send(:"evaluate_#{node_type}", node, data)
    end

    def evaluate_expression(node, data)
      data.dig(*node["value"].split("."))
    end

    def evaluate_operation(node, data)
      evaluated_arguments = node["arguments"].map { |a| evaluate_node(a, data) }
      apply_function(node["function"], evaluated_arguments, data)
    end

    def evaluate_value(node, _data)
      node["value"]
    end

    def apply_function(function_name, arguments, data)
      send(:"apply_function_#{function_name}", arguments, data)
    end

    def apply_function_add(arguments, _data = nil)
      return arguments[0] if arguments.length == 1
      arguments[0] + apply_function_add(arguments[1..-1])
    end

    def apply_function_api_call(arguments, data)
      verb = arguments[0]
      target = arguments[1]
      payload = arguments[2]
      TrelloClient.api_call(verb, target, payload)
    end

    def apply_function_min(arguments, _data)
      arguments.min
    end

    def apply_function_extract(arguments, _data)
      path = arguments[0]
      data_to_extract = arguments[1]
      data_to_extract.map do |value|
        value[path]
      end
    end

    def apply_function_map(arguments, _data)
      mapping_table = arguments[1]
      mapped_values = arguments[0]
      mapped_values.map do |value|
        mapping_table[value]
      end
    end

    def workflows
      config["workflows"]
    end
  end
end
