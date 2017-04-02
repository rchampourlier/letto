# frozen_string_literal: true
require_relative '../node'

module Letto
  module Workflows

    # An `OperationNode` enables performing an operation. An operation
    # is defined by a function and an array of arguments. The available
    # functions are defined in workflows/functions.
    class OperationNode < Node
      ERR_MSG_FUNCTION_MISSING = 'Operation node must have a function (%s)'
      ERR_MSG_FUNCTION_UNKNOWN = 'Function \"%s\" is unknown (%s)'
      ERR_MSG_ARGUMENTS_MISSING = 'Operation node must have arguments (%s)'
      ERR_MSG_ARGUMENTS_NOT_HASH = 'Operation node arguments must be an hash (%s)'
      ERR_MSG_FUNCTION_RUNTIME_FAILURE = 'Function runtime failure (%s)'

      # TODO: discover using introspection instead
      SUPPORTED_FUNCTION_NAMES = %w(
        api_call
        convert
        extract
        map
        min
        log
        replace_pattern
        sum
      ).freeze

      def evaluate(context:)
        evaluated_args = arguments.each_with_object({}) do |(k, v), hash|
          hash[k] = Node.build(data: v).evaluate(context: context)
        end
        function.run(
          arguments: evaluated_args,
          context: context
        )
      rescue Function::Error => e
        raise_error(message: ERR_MSG_FUNCTION_RUNTIME_FAILURE, params: [e])
      end

      def check!
        ensure_has_function!
        ensure_supported_function!
        ensure_valid_arguments!
      end

      private

      def ensure_has_function!
        return unless function_name.nil?
        raise_error message: ERR_MSG_FUNCTION_MISSING
      end

      def ensure_supported_function!
        return if SUPPORTED_FUNCTION_NAMES.include?(function_name)
        raise_error message: ERR_MSG_FUNCTION_UNKNOWN, params: [function_name, data]
      end

      def ensure_valid_arguments!
        ensure_arguments_present!
        ensure_arguments_is_an_hash!
      end

      def ensure_arguments_present!
        return unless arguments.nil?
        raise_error message: ERR_MSG_ARGUMENTS_MISSING
      end

      def ensure_arguments_is_an_hash!
        return if arguments.is_a?(Hash)
        raise_error message: ERR_MSG_ARGUMENTS_NOT_HASH
      end

      def function
        Function.for_name(name: function_name).new
      end

      def function_name
        data['function']
      end

      def arguments
        data['arguments']
      end
    end
  end
end
