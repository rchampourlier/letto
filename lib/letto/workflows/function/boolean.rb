# frozen_string_literal: true
require "workflows/function"

module Letto
  module Workflows
    module Function

      # Applies a boolean operation over the specified values.
      class Boolean < Base
        EXPECTED_ARGUMENTS = %w(values operation).freeze
        SUPPORTED_OPERATIONS = %w(and or).freeze
        ERR_MSG_TARGET_TYPE_NOT_SUPPORTED = "Function `convert` does not support target type %s"
        ERR_MSG_OPERATION_INVALID_UNKNOWN = "the `%s` operation for a boolean function is unknown"
        ERR_MSG_VALUES_INVALID_MUST_BE_ARRAY = "the values attribute for the boolean function must be an array (%s)"
        ERR_MSG_VALUES_INVALID_MUST_BE_BOOLEANS = "the values for the boolean function must be booleans (%s)"

        def run_after
          ensure_operation_valid!
          ensure_values_valid!
          send(:"apply_#{operation}", values)
        end

        private

        def apply_and(values)
          values.all? { |v| v == true }
        end

        def apply_or(values)
          values.any? { |v| v == true }
        end

        def ensure_operation_valid!
          ensure_operation_supported!
        end

        def ensure_operation_supported!
          return if SUPPORTED_OPERATIONS.include?(operation)
          raise_error(message: format(ERR_MSG_OPERATION_INVALID_UNKNOWN, operation))
        end

        def ensure_values_valid!
          ensure_values_is_array!
          ensure_values_are_booleans!
        end

        def ensure_values_is_array!
          return if values.is_a?(Array)
          raise_error(message: format(ERR_MSG_VALUES_INVALID_MUST_BE_ARRAY, values))
        end

        def ensure_values_are_booleans!
          return if values.all? { |v| v.is_a?(Boolean) }
          raise_error(message: format(ERR_MSG_VALUES_INVALID_MUST_BE_BOOLEANS, values))
        end
      end
    end
  end
end
