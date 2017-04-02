# frozen_string_literal: true
require_relative '../node'

module Letto
  module Workflows

    # An expression node enables to build values dynamically
    # by evaluating the provided expression.
    #
    # An expression node must have the following attributes:
    #   - `type`: `expression`
    #   - `value_type`: `value`, `array` or `hash`
    #   - `value`
    #
    # Depending on the `value_type`, the `value` may take different
    # forms:
    #   - `value`:
    #     - static: e.g. a numeric (2), a string ('something'),
    #     - dynamic: e.g. an expression to be evaluated against the
    #       context, like `{{ context.path.to.value }}`
    #   - `array` or `hash`, where each item or value is itself
    #     an expression node.
    #
    # TODO: rename `value_type` to `expression_type`
    class ExpressionNode < Node
      ERR_MSG_VALUE_TYPE_MISSING = 'Expression nodes must have a `value_type` (%s)'
      ERR_MSG_VALUE_TYPE_INVALID = '`value_type` is not valid, should be one of \"value\", \"array\" or \"hash\" (%s)'
      ERR_MSG_VALUE_MISSING = 'Expression nodes must have a `value` attribute (%s)'
      ERR_MSG_VALUE_INVALID_NOT_ARRAY = \
        '`value` for an expression node with \"array\" `value_type` must be an array (%s)'
      ERR_MSG_VALUE_INVALID_NOT_HASH = '`value` for an expression node with \"hash\" `value_type` must be an hash (%s)'
      ERR_MSG_NESTED_EXPRESSIONS_INVALID = 'Nested expressions are not valid (%s)'
      ERR_MSG_VALUE_INVALID_FOR_VALUE_TYPE = \
        'Value for a \"value\" `value_type` must be Numeric or String (%s)'

      SUPPORTED_VALUE_TYPES = %w(value array hash).freeze

      def evaluate(context:)
        check!
        send(:"evaluate_#{value_type}", context: context)
      end

      def check!
        check_value_type_present!
        check_value_type_valid!
        check_value_present!
        check_value_content!
      end

      private

      def check_value_type_present!
        return unless value_type.nil?
        raise_error message: ERR_MSG_VALUE_TYPE_MISSING
      end

      def check_value_type_valid!
        return if SUPPORTED_VALUE_TYPES.include?(value_type)
        raise_error message: ERR_MSG_VALUE_TYPE_INVALID
      end

      def check_value_present!
        return unless value.nil?
        raise_error message: ERR_MSG_VALUE_MISSING
      end

      def check_value_content!
        send(:"check_value_content_#{value_type}!")
      end

      def check_value_content_value!
        return if value.is_a?(String) || value.is_a?(Numeric)
        raise_error message: ERR_MSG_VALUE_INVALID_FOR_VALUE_TYPE
      end

      def check_value_content_array!
        raise_error(message: ERR_MSG_VALUE_INVALID_NOT_ARRAY) unless value.is_a?(Array)
        check_nested_expressions!(value)
      end

      def check_value_content_hash!
        raise_error(message: ERR_MSG_VALUE_INVALID_NOT_HASH) unless value.is_a?(Hash)
        check_nested_expressions!(value.values)
      end

      def check_nested_expressions!(nodes)
        nodes.map { |item| ExpressionNode.new(data: item).check! }
      rescue Error => e
        raise(Error, format(ERR_MSG_NESTED_EXPRESSIONS_INVALID, e))
      end

      def evaluate_value(context:)
        value = data['value']
        return value unless value.is_a?(String)

        re = /{{(.*)}}/
        expression = value[re, 1]
        return value unless expression

        expression = expression.strip
        evaluated_expression = context.dig(*expression.split('.'))
        value.gsub(re, evaluated_expression)
      end

      def evaluate_array(context:)
        value = data['value']
        value.map do |item|
          ExpressionNode.new(data: item).evaluate(context: context)
        end
      end

      def evaluate_hash(context:)
        value = data['value']
        value.each_with_object({}) do |(k, v), hash|
          hash[k] = ExpressionNode.new(data: v).evaluate(context: context)
        end
      end

      def value
        data['value']
      end

      def value_type
        data['value_type']
      end
    end
  end
end
