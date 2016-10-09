# frozen_string_literal: true
module Letto

  class WorkflowsChecker
    SUPPORTED_NODE_TYPES = %w(expression operation value target payload).freeze
    SUPPORTED_FUNCTION_NAMES = %w(add api_call map min convert extract).freeze
    SUPPORTED_CONVERSION_FUNCTIONS = %w(String Complex Float Integer Rational DateTime).freeze
    SUPPORTED_VERBS = %w(GET POST PUT DELETE).freeze

    def self.check_workflows(workflows)
      raise "No workflows to check" if workflows.nil?
      workflows.all? {|workflow| check_workflow(workflow)}
    end

    private

    def self.check_workflow(workflow)
      name = workflow["name"]
      # should have a name
      raise "Workflows should have a name" if name.nil?
      # should have at least one condition on board ID
      raise "Workflows should have a conditions block (" + name + ")" if workflow["conditions"].nil?
      raise "Workflows should have an array in condition block (" + name + ")" if !workflow["conditions"].is_a?(Array)
      raise "Workflows should have at least one condition on model.id (" + name + ")" if workflow["conditions"].none? {|a| a["path"]=="model.id"}
      # shouls have an action
      raise "Workflows should have an action (" + name + ")" if workflow["action"].nil?
      # each block in action shoud
      return check_block_in_workflow(workflow["action"])
    end

    def self.check_block_in_workflow(block)
      type = block["type"]
      # should have a type
      raise "Blocks should have a type "+ block.to_s if type.nil?
      # should be a supported type
      raise "Blocks should have a supported type "+ block.to_s if !verify_supported_node_type!(type)
      if type == "operation"
        function = block["function"]
        arguments = block["arguments"]
        # should have a function name
        raise "Opeation blocks should have a function name block "+ block.to_s if function.nil?
        # should be a supported function
        raise "Opeation blocks should have a supported function name "+ block.to_s if !verify_supported_function!(function)
        # should have arguments
        raise "Opeation blocks should have an arguments block "+ block.to_s if arguments.nil?
        # arguments should be an array
        raise "Opeation blocks should have an array in arguments block "+ block.to_s if !arguments.is_a?(Array)
        # check all arguments
        return arguments.all? {|argument| check_block_in_workflow(argument)}
        # check on arguments
        if function == "api_call"
          # should have 3 arguments : verb, target, payload
          raise "Wrong number of arguments in api_call block - should be 3 "+ block.to_s if arguments.length != 3
          verify_supported_verb!(arguments[0]["value"]) if arguments[0]["type"] == "value"
          raise "Argument 2 should be a target in api_call blocks "+ block.to_s if arguments[1]["type"] != "target"
          raise "Argument 3 should be a payload in api_call blocks "+ block.to_s if arguments[1]["type"] != "payload"
        elsif function == "convert"
          # should have 2 arguments : dest, value
          verify_supported_conversion_function!(arguments[0]["value"]) if arguments[0]["type"] == "value"
        end
      else
        # if other type, a value
        value = block["value"]
        raise "Blocks others than operation should have a value "+ block.to_s if value.nil?
        if type == "payload"
          return value.all? {|val| check_block_in_workflow(val)}
        end
      end
    end

    def self.verify_supported_node_type!(node_type)
      return true if SUPPORTED_NODE_TYPES.include?(node_type)
      raise "Unknown node type: #{node_type}"
    end

    def self.verify_supported_function!(function_name)
      return true if SUPPORTED_FUNCTION_NAMES.include?(function_name)
      raise "Unknown function name: #{function_name}"
    end

    def self.verify_supported_conversion_function!(function_name)
      return true if SUPPORTED_CONVERSION_FUNCTIONS.include?(function_name)
      raise "Unknown conversion function name: #{function_name}"
    end

    def self.verify_supported_verb!(verb)
      return true if SUPPORTED_VERBS.include?(verb.upcase)
      raise "Unknown verb: #{node_type}"
    end


  end
end
