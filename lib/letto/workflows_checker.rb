# frozen_string_literal: true
module Letto

  # Checker for workflows structures
  class WorkflowsChecker
    SUPPORTED_NODE_TYPES = %w(expression operation payload).freeze
    SUPPORTED_FUNCTION_NAMES = %w(add api_call map min convert extract get_linkedin_photo gsub).freeze
    SUPPORTED_CONVERSION_FUNCTIONS = %w(String Complex Float Integer Rational DateTime).freeze
    SUPPORTED_COMPARISON_TYPES = %w(string_comparison regex_comparison).freeze
    SUPPORTED_VERBS = %w(GET POST PUT DELETE).freeze

    FUNCTION_ADD_EXPECTED_ARGS = %w(* ...).freeze
    FUNCTION_API_CALL_EXPECTED_ARGS = %w(expression expression [payload]).freeze
    FUNCTION_MAP_EXPECTED_ARGS = %w(* *).freeze
    FUNCTION_MIN_EXPECTED_ARGS = %w(* ...).freeze
    FUNCTION_CONVERT_EXPECTED_ARGS = %w(expression *).freeze
    FUNCTION_EXTRACT_EXPECTED_ARGS = %w(expression *).freeze
    FUNCTION_GET_LINKEDIN_PHOTO_EXPECTED_ARGS = %w(*).freeze
    FUNCTION_GSUB_EXPECTED_ARGS = %w(* expression expression expression).freeze
    RE_OPTIONAL_ARGS = /\[(.*)\]/

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
    ERR_MSG_BLOCK_OPERATION_WRONG_MIN_NB_ARGS = "Wrong number of arguments in %s block - should be %s %s"
    ERR_MSG_BLOCK_OPERATION_ARG_WRONG_TYPE = "Argument %i should be a %s in %s blocks %s"

    ERR_MSG_NODE_TYPE_NOT_SUPPORTED = "Unknown node type: %s"
    ERR_MSG_FUNCTION_NOT_SUPORTED = "Unknown function name: %s"
    ERR_MSG_CONVERSION_FUNCTION_NOT_SUPPORTED = "Unknown conversion function name: %s"
    ERR_MSG_VERB_NOT_SUPPORTED = "Unknown verb: %s"
    ERR_MSG_COMPARISON_TYPE_NOT_SUPPORTED = "Unknow comparison type : %s"

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
      # comparison types should exist and be supported
      workflow["conditions"].each { |a| verify_supported_comparison_type!(a["type"]) }
      # should have an action
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
      check_block_operation_arguments(block)
      case function
      when "api_call"
        check_block_operation_api_call!(block)
      when "convert"
        check_block_operation_convert!(block)
      when "gsub"
        check_block_operation_gsub!(block)
      end
    end

    def self.check_block_operation_api_call!(block)
      arguments = block["arguments"]
      verify_supported_verb!(arguments[0]["value"])
    end

    def self.check_block_operation_convert!(block)
      arguments = block["arguments"]
      verify_supported_conversion_function!(arguments[0]["value"])
    end

    def self.check_block_operation_gsub!(block)
      arguments = block["arguments"]
      verify_supported_comparison_type!(arguments[1]["value"])
    end

    def self.check_block_operation_arguments(block)
      function = block["function"]
      arguments = block["arguments"]
      constraints = const_get("FUNCTION_#{function.upcase}_EXPECTED_ARGS")
      check_block_operation_arguments_nb!(function, arguments, constraints, block)
      check_block_operation_arguments_types!(function, arguments, constraints, block)
    end

    def self.check_block_operation_arguments_nb!(function, arguments, constraints, block)
      if constraints.last == "..."
        # test the minimum number of aruments
        nb_args = constraints.length - 1
        raise_workflow_error format(ERR_MSG_BLOCK_OPERATION_WRONG_NB_ARGS, function, "at least #{nb_args}", block) unless arguments.length >= nb_args
      elsif RE_OPTIONAL_ARGS !~ constraints.last
        # test the number of args
        nb_args = constraints.length
        raise_workflow_error format(ERR_MSG_BLOCK_OPERATION_WRONG_NB_ARGS, function, nb_args, block) unless arguments.length == nb_args
      else
        # test if there is optional args
        min_args = constraints.count { |constraint| !constraint[RE_OPTIONAL_ARGS] }
        max_args = constraints.length
        raise_workflow_error format(ERR_MSG_BLOCK_OPERATION_WRONG_NB_ARGS, function, "between #{min_args} and #{max_args}", block) unless arguments.length >= min_args && arguments.length <= max_args
      end
    end

    def self.check_block_operation_arguments_types!(function, arguments, constraints, block)
      arguments.each_index do |i|
        constraint = constraints[i]
        argument_type = arguments[i]["type"]
        break if constraint == "..."
        next if constraint == "*"
        unless RE_OPTIONAL_ARGS !~ constraint
          constraint = constraint.match(RE_OPTIONAL_ARGS)[1]
        end
        raise_workflow_error format(ERR_MSG_BLOCK_OPERATION_ARG_WRONG_TYPE, i + 1, constraint, function, block) if argument_type != constraint
      end
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

    def self.verify_supported_comparison_type!(type)
      return true if SUPPORTED_COMPARISON_TYPES.include?(type)
      raise_workflow_error format(ERR_MSG_COMPARISON_TYPE_NOT_SUPPORTED, type)
    end
  end
end
