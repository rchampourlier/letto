# frozen_string_literal: true
require_relative '../function'

module Letto
  module Workflows
    module Function

      # Applies a boolean operation over the specified values.
      class Compare < Base
        EXPECTED_ARGUMENTS = %w(value1 value2 operation).freeze
        SUPPORTED_OPERATIONS = %w(equality).freeze
        # ERR_MSG_VALUES_INVALID_MUST_BE_BOOLEANS = "the values for the boolean function must be booleans (%s)"

        def run_after
          send(:"compare_with_#{operation}")
        end

        private

        def compare_with_equality
          value1 == value2
        end

        # def ensure_values_are_booleans!(values)
        #   return if values.all? { |v| v.is_a?(Boolean) }
        #   raise_error(message: format(ERR_MSG_VALUES_INVALID_MUST_BE_BOOLEANS, values))
        # end
      end
    end
  end
end
