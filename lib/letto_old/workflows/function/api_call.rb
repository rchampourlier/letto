# frozen_string_literal: true
require "workflows/function"

module Letto
  module Workflows
    module Function

      # Performs an API call to the Trello API.
      class ApiCall < Base
        EXPECTED_ARGUMENTS = %w(verb target payload).freeze

        def run_after
          Integrations::Trello.perform_api_call(
            user_uuid: context["user_uuid"],
            verb: verb,
            target: target,
            payload: payload
          )
        end
      end
    end
  end
end
