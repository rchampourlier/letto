# frozen_string_literal: true
require "workflows/function"

module Letto
  module Workflows
    module Function

      # Maps values in an array to another array using
      # a mapping table.
      #
      # Takes 2 arguments:
      #   - "mapping_table": an hash which will be used to map
      #     values from the second arguments
      #   - "values": an array of values to be mapped using the
      #     hash
      class Map < Base
        EXPECTED_ARGUMENTS = %w(mapping_table values).freeze

        def run_after
          values.map do |value|
            mapping_table[value]
          end
        end
      end
    end
  end
end
