# frozen_string_literal: true
require_relative '../function'

module Letto
  module Workflows
    module Function

      # Addition function.
      # Currently only works on numeric values.
      class Sum < Base
        EXPECTED_ARGUMENTS = %w(values).freeze

        def run_after
          values.inject(0) { |a, e| a + e }
        end
      end
    end
  end
end
