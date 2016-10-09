# frozen_string_literal: true

require "workflows_checker"
module Letto

  # The runner
  class Runner
    attr_reader :config
    attr_reader :users_webhooks_cache

    def initialize(config, users_webhooks_cache)
      @config = config
      @users_webhooks_cache = users_webhooks_cache
      WorkflowsChecker.check_workflows(workflows)
    end

    def handle_webhook(webhook)
      matching_workflows(webhook).each do |workflow|
        execute_action(workflow["action"], webhook)
      end
    end

    def matching_workflows(webhook)
      filter_workflows_on_conditions(workflows, webhook)
    end

    def execute_action(action, webhook)
      evaluate_node(action, webhook.parsed_body, webhook.id)
    end

    private

    def filter_workflows_on_conditions(workflows, webhook)
      workflows.select { |w| verifies_workflow_conditions(w, webhook) }
    end

    def verifies_workflow_conditions(workflow, webhook)
      workflow["conditions"].each do |condition|
        return false unless verify_workflow_expected_values(condition, webhook)
      end
      true
    end

    def verify_workflow_expected_values(condition, webhook)
      type = condition["type"]
      expected_values = condition["value"]
      path = condition["path"]
      if expected_values.is_a?(Array)
        expected_values.each do |expected_value|
          return true if verify_workflow_condition(type, expected_value, path, webhook)
        end
        false
      else
        return verify_workflow_condition(type, expected_values, path, webhook)
      end
    end

    def verify_workflow_condition(type, expected_value, path, webhook)
      if type == "string_comparison"
        observed_value = webhook.parsed_body.dig(*path.split("."))
        return expected_value == observed_value
      end
      raise "Unknown condition type: #{condition['type']}"
    end

    def evaluate_target(node, data, _webhook_id = nil)
      raw_target = node["value"]
      re = /{{(.*)}}/
      expression = raw_target[re, 1].strip
      evaluated_expression = evaluate_expression({ "value" => expression }, data)
      raw_target.gsub(re, evaluated_expression)
    end

    def evaluate_payload(node, data, webhook_id = nil)
      payload = node["value"]
      payload.each_with_object({}) do |(argument, node), evaluated_args|
        evaluated_args[argument] = evaluate_node(node, data, webhook_id)
      end
    end

    def evaluate_node(node, data, webhook_id)
      node_type = node["type"]
      send(:"evaluate_#{node_type}", node, data, webhook_id)
    end

    def evaluate_expression(node, data, _webhook_id = nil)
      data.dig(*node["value"].split("."))
    end

    def evaluate_operation(node, data, webhook_id)
      evaluated_arguments = node["arguments"].map { |a| evaluate_node(a, data, webhook_id) }
      apply_function(node["function"], evaluated_arguments, data, webhook_id)
    end

    def evaluate_value(node, _data, _webhook_id = nil)
      node["value"]
    end

    def apply_function(function_name, arguments, data, webhook_id)
      send(:"apply_function_#{function_name}", arguments, data, webhook_id)
    end

    def apply_function_add(arguments, _data = nil, _webhook_id = nil)
      if arguments.length == 1
        return 0 if arguments[0].nil?
        return arguments[0]
      end
      arguments[0] + apply_function_add(arguments[1..-1])
    end

    def apply_function_api_call(arguments, data, webhook_id)
      verb = arguments[0]
      target = arguments[1]
      payload = arguments[2]
      trello_client = @users_webhooks_cache.trello_client_from_callback(webhook_id);
      JSON.load(trello_client.api_call(verb, target, payload))
    end

    def apply_function_min(arguments, _data, _webhook_id = nil)
      if (arguments.length > 1 && arguments.find {|a| a.class == "Array"})
        raise "function min takes 1 array as argument or multiple simple values"
      end
      arguments.flatten.compact.min
    end

    def apply_function_extract(arguments, _data, _webhook_id = nil)
      path = arguments[0]
      data_to_extract = arguments[1]
      if data_to_extract.is_a?(Array)
        data_to_extract.map do |value|
          value[path]
        end
      elsif data_to_extract.is_a?(Hash)
        data_to_extract[path]
      end
    end

    def apply_function_map(arguments, _data, _webhook_id = nil)
      mapping_table = arguments[1]
      mapped_values = arguments[0]
      mapped_values.map do |value|
        mapping_table[value]
      end
    end

    def apply_function_convert(arguments, _data, _webhook_id = nil)
      dest_type = arguments[0]
      value = arguments[1]
      return DateTime.parse(value) if dest_type == "DateTime" 
      return send(:"#{dest_type}", value)
    end

    def workflows
      config["workflows"]
    end

  end
end
