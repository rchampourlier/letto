# frozen_string_literal: true
require "workflows/function"

module Letto
  module Workflows
    module Function

      # Extracts subset of data (array or hash) using a path
      # identifier.
      class Extract < Base
        EXPECTED_ARGUMENTS = %w(path data).freeze

        def run_after
          if data.is_a?(Array)
            data.map do |value|
              value[path]
            end
          elsif data.is_a?(Hash)
            data[path]
          end
        end
      end
    end
  end
end
