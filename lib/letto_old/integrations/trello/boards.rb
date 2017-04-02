# frozen_string_literal: true
require "integrations/trello/client"

module Letto
  module Integrations
    module Trello

      # Authentication component for the Trello integration.
      class Boards

        # Sinatra helpers for the Trello/Boards routes
        module Helpers
          attr_reader :user

          # Returns the list of boards by fetching from the Trello API.
          def boards
            @boards ||= Trello.client(user: user).boards.map(&:attributes)
          end

          # Returns only active boards.
          def active_boards
            boards.select { |board| board[:closed] == false }
          end

          def organizations_and_boards
            @organizations_and_boards ||= (
              organizations = fetch_organizations
              active_boards.each_with_object({}) do |board, hash|
                organization_id = board[:organization_id]
                matching_organization = organizations.find { |organization| organization[:id] == organization_id }
                hash[organization_id] ||= {
                  display_name: matching_organization ? matching_organization[:display_name] : organization_id,
                  boards: []
                }
                create_webhook_url = "/trello/boards/#{board[:id]}/create_webhook?board_name=#{board[:name]}"
                hash[organization_id][:boards].push([board, create_webhook_url])
              end
            )
          end

          def create_webhook(board_id:, description:)
            url = IncomingWebhooks.create(
              integration: "trello",
              user_uuid: user[:id],
              context: { board_id: board_id }
            )
            Trello.client(user: user).create_board_webhook(
              board_id,
              url,
              description
            )
          end

          def fetch_organizations
            organizations = Trello.client(user: user).organizations.map(&:attributes)
            organizations.push(display_name: "No Team", id: nil)
            organizations
          end
        end

        # Include the routes for Trello::Authentication in the
        # top-level application using:
        # `register Letto::Integrations::Trello::Boards::Routes`
        module Routes

          def self.registered(app)
            app.helpers { include Helpers }
            app.before do
              @user = Persistence::UserRepository.for_session_id(session[:session_id])
            end

            app.get "/boards" do
              @organizations_and_boards = organizations_and_boards
              erb :trello_boards
            end

            app.get "/boards/:board_id/create_webhook" do
              board_name = params[:board_name]
              Boards.new.create_webhook(
                board_id: params[:board_id],
                description: "Trello webhook on board \"#{board_name}\""
              )
              redirect "/trello/webhooks"
            end
          end
        end
      end
    end
  end
end
