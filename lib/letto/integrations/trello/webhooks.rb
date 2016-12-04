# frozen_string_literal: true
require "sinatra/base"

module Letto
  module Integrations
    module Trello

      class Webhooks

        module Helpers
          attr_reader :user
        end

        # Include the routes for Trello::Authentication in the
        # top-level application using
        # `register Letto::Integrations::Trello::Boards::Routes`
        module Routes

          def self.registered(app)
            app.helpers { include Helpers }
            app.before do
              @user = Persistence::UserRepository.for_session_id(session[:session_id])
            end

            app.get "/webhooks/delete_webhook/:webhook_id" do
              webhook_id = params[:webhook_id]
              Trello.client(user: user).delete_webhook(
                webhook_id
              )
              redirect "/trello/webhooks"
            end

            app.get "/webhooks" do
              @webhooks = Trello.client(user: user).webhooks.map(&:attributes)
              @delete_webhook_urls = @webhooks.map do |webhooks|
                "/trello/webhooks/delete_webhook/#{webhooks[:id]}"
              end
              erb :trello_webhooks
            end
          end
        end
      end
    end
  end
end
