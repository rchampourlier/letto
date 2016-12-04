# frozen_string_literal: true
require "workflows/function"

module Letto
  module Workflows
    module Function

      # Converts the value into the specified target type.
      class Convert < Base
        EXPECTED_ARGUMENTS = %w(value target_type).freeze
        SUPPORTED_TARGET_TYPES = %w(datetime).freeze
        ERR_MSG_TARGET_TYPE_NOT_SUPPORTED = "Function `convert` does not support target type %s"

        def run_after
          ensure_supported_target_type!
          send(:"convert_to_#{target_type}")
        end

        private

        def ensure_supported_target_type!
          return if SUPPORTED_TARGET_TYPES.include?(target_type)
          raise_error(message: format(ERR_MSG_TARGET_TYPE_NOT_SUPPORTED, target_type))
        end

        def convert_to_datetime
          DateTime.parse(value)
        end
      end
    end
  end
end
