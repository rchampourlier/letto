# frozen_string_literal: true
module Letto

  # Checker for workflows structures
  class WorkflowsChecker
    SUPPORTED_NODE_TYPES = %w(expression operation payload).freeze
    SUPPORTED_FUNCTION_NAMES = %w(add api_call map min convert extract get_linkedin_photo).freeze
    SUPPORTED_CONVERSION_FUNCTIONS = %w(String Complex Float Integer Rational DateTime).freeze
    SUPPORTED_VERBS = %w(GET POST PUT DELETE).freeze

    ERR_MSG_NO_WORKFLOWS = "No workflows to check"
    ERR_MSG_NO_NAME = "Workflow should have a name"
    ERR_MSG_NO_CONDITIONS = "Workflow should have a conditions block (%s)"
    ERR_MSG_CONDITIONS_IS_NOT_ARRAY = "Workflow should have an array in condition block (%s)"
    ERR_MSG_CONDITIONS_HAS_NONE_ON_MODEL_ID = "Workflow should have at least one condition on model.id (%s)"
    ERR_MSG_NO_ACTION = "Workflow should have an action (%s)"

    ERR_MSG_BLOCK_NO_TYPE = "Blocks should have a type %s"
    ERR_MSG_BLOCK_NO_VALUE = "Blocks others than operation should have a value %s"

    ERR_MSG_BLOCK_OPERATION_NO_FUNCTION = "Operation blocks should have a function name block %s"
    ERR_MSG_BLOCK_OPERATION_NO_ARGUMENTS = "Operation blocks should have an arguments block %s"
    ERR_MSG_BLOCK_OPERATION_ARGUMENT_IS_NOT_ARRAY = "Operation blocks should have an array in arguments block %s"

    ERR_MSG_BLOCK_OPERATION_WRONG_NB_ARGS = "Wrong number of arguments in %s block - should be %s %s"
    ERR_MSG_BLOCK_OPERATION_ARG_WRONG_TYPE = "Argument %i should be a %s in %s blocks %s"

    ERR_MSG_NODE_TYPE_NOT_SUPPORTED = "Unknown node type: %s"
    ERR_MSG_FUNCTION_NOT_SUPORTED = "Unknown function name: %s"
    ERR_MSG_CONVERSION_FUNCTION_NOT_SUPPORTED = "Unknown conversion function name: %s"
    ERR_MSG_VERB_NOT_SUPPORTED = "Unknown verb: %s"

    Error = Class.new(StandardError)

    def self.check_workflows!(workflows)
      raise_workflow_error ERR_MSG_NO_WORKFLOWS if workflows.nil?
      workflows.all? { |workflow| check_workflow!(workflow) }
    end

    def self.raise_workflow_error(message)
      raise Error, message
    end

    def self.check_workflow!(workflow)
      name = workflow["name"]
      # should have a name
      raise_workflow_error ERR_MSG_NO_NAME if name.nil?
      # should have at least one condition on board ID
      raise_workflow_error format(ERR_MSG_NO_CONDITIONS, name) if workflow["conditions"].nil?
      raise_workflow_error format(ERR_MSG_CONDITIONS_IS_NOT_ARRAY, name) unless workflow["conditions"].is_a?(Array)
      raise_workflow_error format(ERR_MSG_CONDITIONS_HAS_NONE_ON_MODEL_ID, name) if workflow["conditions"].none? { |a| a["path"] == "model.id" }
      # shouls have an action
      raise_workflow_error format(ERR_MSG_NO_ACTION, name) if workflow["action"].nil?
      # each block in action shoud
      check_block!(workflow["action"])
    end

    def self.check_block!(block)
      type = block["type"]
      # should have a type
      raise_workflow_error format(ERR_MSG_BLOCK_NO_TYPE, block) if type.nil?
      # should be a supported type
      verify_supported_node_type!(type)
      if type == "operation"
        check_block_operation!(block)
      else
        # if other type, a value
        value = block["value"]
        raise_workflow_error format(ERR_MSG_BLOCK_NO_VALUE, block) if value.nil?
        value.each { |_k, v| check_block!(v) } if type == "payload"
      end
    end

    def self.check_block_operation!(block)
      function = block["function"]
      arguments = block["arguments"]
      # should have a function name
      raise_workflow_error format(ERR_MSG_BLOCK_OPERATION_NO_FUNCTION, block) if function.nil?
      # should be a supported function
      verify_supported_function!(function)
      # should have arguments
      raise_workflow_error format(ERR_MSG_BLOCK_OPERATION_NO_ARGUMENTS, block) if arguments.nil?
      # arguments should be an array
      raise_workflow_error format(ERR_MSG_BLOCK_OPERATION_ARGUMENT_IS_NOT_ARRAY, block) unless arguments.is_a?(Array)
      # check all arguments
      arguments.each { |argument| check_block!(argument) }
      # check on arguments
      if function == "api_call"
        check_block_operation_api_call!(block)
      elsif function == "convert"
        check_block_operation_convert!(block)
      end
    end

    def self.check_block_operation_api_call!(block)
      arguments = block["arguments"]
      # should have 3 arguments : verb, expression, payload
      # or 2 arguments : verb, expression
      raise_workflow_error format(ERR_MSG_BLOCK_OPERATION_WRONG_NB_ARGS, "api_call", "2 or 3", block) unless arguments.length == 3 || arguments.length == 2
      raise_workflow_error format(ERR_MSG_BLOCK_OPERATION_ARG_WRONG_TYPE, 1, "expression", "api_call", block) if arguments[0]["type"] != "expression"
      verify_supported_verb!(arguments[0]["value"])
      raise_workflow_error format(ERR_MSG_BLOCK_OPERATION_ARG_WRONG_TYPE, 2, "expression", "api_call", block) if arguments[1]["type"] != "expression"
      raise_workflow_error format(ERR_MSG_BLOCK_OPERATION_ARG_WRONG_TYPE, 3, "payload", "api_call", block) if arguments.length == 3 && arguments[2]["type"] != "payload"
    end

    def self.check_block_operation_convert!(block)
      arguments = block["arguments"]
      # should have 2 arguments : dest, value
      raise_workflow_error format(ERR_MSG_BLOCK_OPERATION_WRONG_NB_ARGS, "convert", "2", block) unless arguments.length == 2
      raise_workflow_error format(ERR_MSG_BLOCK_OPERATION_ARG_WRONG_TYPE, 1, "expression", "convert", block) if arguments[0]["type"] != "expression"
      verify_supported_conversion_function!(arguments[0]["value"])
      raise_workflow_error format(ERR_MSG_BLOCK_OPERATION_ARG_WRONG_TYPE, 2, "expression", "convert", block) if arguments[1]["type"] != "expression"
    end

    def self.verify_supported_node_type!(node_type)
      return true if SUPPORTED_NODE_TYPES.include?(node_type)
      raise_workflow_error format(ERR_MSG_NODE_TYPE_NOT_SUPPORTED, node_type)
    end

    def self.verify_supported_function!(function_name)
      return true if SUPPORTED_FUNCTION_NAMES.include?(function_name)
      raise_workflow_error format(ERR_MSG_FUNCTION_NOT_SUPORTED, function_name)
    end

    def self.verify_supported_conversion_function!(function_name)
      return true if SUPPORTED_CONVERSION_FUNCTIONS.include?(function_name)
      raise_workflow_error format(ERR_MSG_CONVERSION_FUNCTION_NOT_SUPPORTED, function_name)
    end

    def self.verify_supported_verb!(verb)
      return true if SUPPORTED_VERBS.include?(verb.upcase)
      raise_workflow_error format(ERR_MSG_VERB_NOT_SUPPORTED, verb)
    end
  end
end
