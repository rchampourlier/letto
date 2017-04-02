# frozen_string_literal: true
require_relative '../../../../../../lib/letto/repositories/integration_repository'

module Web::Controllers
  module Integrations
    module Trello
      module Connection

        # Initialize Trello integration OAuth connection
        class Destroy
          include Web::Action

          def initialize(event: TrelloConnectionRemovedByUser.new)
            @event = event
          end

          def call(_params)
            @event.call(user_uuid: user_uuid)
            redirect_to routes.root_path
          end

          private

          def user_uuid
            session[:user_uuid]
          end
        end
      end
    end
  end
end
