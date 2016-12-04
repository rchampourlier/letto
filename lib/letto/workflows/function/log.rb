# frozen_string_literal: true
require "workflows/function"

module Letto
  module Workflows
    module Function

      # Logs the `message` parameter and returns it.
      class Log < Base
        EXPECTED_ARGUMENTS = %w(message).freeze

        def run_after
          LOGGER.info(message)
          message
        end
      end
    end
  end
end
