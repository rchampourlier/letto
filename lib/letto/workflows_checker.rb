# frozen_string_literal: true
module Letto

  class WorkflowsChecker
    SUPPORTED_NODE_TYPES = %w(expression operation value target payload).freeze
    SUPPORTED_FUNCTION_NAMES = %w(add api_call map min convert extract get_linkedin_photo).freeze
    SUPPORTED_CONVERSION_FUNCTIONS = %w(String Complex Float Integer Rational DateTime).freeze
    SUPPORTED_VERBS = %w(GET POST PUT DELETE).freeze

    Error = Class.new(StandardError)

    def self.check_workflows(workflows)
      raise_workflow_error "No workflows to check" if workflows.nil?
      workflows.all? { |workflow| check_workflow(workflow) }
    end

    def self.raise_workflow_error(message)
      raise Error, message
    end

    def self.check_workflow(workflow)
      name = workflow["name"]
      # should have a name
      raise_workflow_error "Workflows should have a name" if name.nil?
      # should have at least one condition on board ID
      raise_workflow_error "Workflows should have a conditions block (#{name})" if workflow["conditions"].nil?
      raise_workflow_error "Workflows should have an array in condition block (#{name})" unless workflow["conditions"].is_a?(Array)
      raise_workflow_error "Workflows should have at least one condition on model.id (#{name})" if workflow["conditions"].none? { |a| a["path"] == "model.id" }
      # shouls have an action
      raise_workflow_error "Workflows should have an action (#{name})" if workflow["action"].nil?
      # each block in action shoud
      check_block_in_workflow(workflow["action"])
    end

    def self.check_block_in_workflow(block)
      type = block["type"]
      # should have a type
      raise_workflow_error "Blocks should have a type #{block}" if type.nil?
      # should be a supported type
      raise_workflow_error "Blocks should have a supported type #{block}" unless verify_supported_node_type!(type)
      if type == "operation"
        function = block["function"]
        arguments = block["arguments"]
        # should have a function name
        raise_workflow_error "Opeation blocks should have a function name block #{block}" if function.nil?
        # should be a supported function
        raise_workflow_error "Opeation blocks should have a supported function name #{block}" unless verify_supported_function!(function)
        # should have arguments
        raise_workflow_error "Opeation blocks should have an arguments block #{block}" if arguments.nil?
        # arguments should be an array
        raise_workflow_error "Opeation blocks should have an array in arguments block #{block}" unless arguments.is_a?(Array)
        # check all arguments
        return arguments.all? { |argument| check_block_in_workflow(argument) }
        # check on arguments
        if function == "api_call"
          # should have 3 arguments : verb, target, payload
          raise_workflow_error "Wrong number of arguments in api_call block - should be 3 #{block}" if arguments.length != 3
          verify_supported_verb!(arguments[0]["value"]) if arguments[0]["type"] == "value"
          raise_workflow_error "Argument 2 should be a target in api_call blocks #{block}" if arguments[1]["type"] != "target"
          raise_workflow_error "Argument 3 should be a payload in api_call blocks #{block}" if arguments[1]["type"] != "payload"
        elsif function == "convert"
          # should have 2 arguments : dest, value
          verify_supported_conversion_function!(arguments[0]["value"]) if arguments[0]["type"] == "value"
        end
      else
        # if other type, a value
        value = block["value"]
        raise_workflow_error "Blocks others than operation should have a value #{block}" if value.nil?
        if type == "payload"
          return value.all? { |val| check_block_in_workflow(val) }
        end
      end
    end

    def self.verify_supported_node_type!(node_type)
      return true if SUPPORTED_NODE_TYPES.include?(node_type)
      raise_workflow_error "Unknown node type: #{node_type}"
    end

    def self.verify_supported_function!(function_name)
      return true if SUPPORTED_FUNCTION_NAMES.include?(function_name)
      raise_workflow_error "Unknown function name: #{function_name}"
    end

    def self.verify_supported_conversion_function!(function_name)
      return true if SUPPORTED_CONVERSION_FUNCTIONS.include?(function_name)
      raise_workflow_error "Unknown conversion function name: #{function_name}"
    end

    def self.verify_supported_verb!(verb)
      return true if SUPPORTED_VERBS.include?(verb.upcase)
      raise_workflow_error "Unknown verb: #{node_type}"
    end
  end
end
