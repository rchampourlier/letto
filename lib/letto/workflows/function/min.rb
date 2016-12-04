# frozen_string_literal: true
require "workflows/function"

module Letto
  module Workflows
    module Function

      # Minimum function.
      # Returns the minimum value in the "values" array.
      #
      # Arguments:
      #   - "values": the values to search the min into
      #
      # TODO: merge min, sum into "arithmetic"
      class Min < Base
        EXPECTED_ARGUMENTS = %w(values).freeze

        def run_after
          values.min
        end
      end
    end
  end
end
