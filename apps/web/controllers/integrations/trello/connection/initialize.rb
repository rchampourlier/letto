# frozen_string_literal: true
module Web::Controllers
  module Integrations
    module Trello
      module Connection

        # Initialize Trello integration OAuth connection
        class Initialize
          include Web::Action

          def initialize(
            oauth_consumer: Connection.oauth_consumer
          )
            @oauth_consumer = oauth_consumer
          end

          def call(_params)
            prepare_session
            redirect_to authorize_url
          end

          private

          # We fetch an OAuth request token and store the token and its secret
          # in the session (aka store). We then return the authorize URL where
          # to redirect to.
          def authorize_url
            request_token = @oauth_consumer.get_request_token(
              oauth_callback: routes.trello_connection_callback_url
            )
            session[:integrations][:trello][:request_token] = request_token.token
            session[:integrations][:trello][:request_token_secret] = request_token.secret
            request_token.authorize_url(AUTHORIZE_URL_PARAMS)
          end

          def prepare_session
            session[:integrations] ||= {}
            session[:integrations][:trello] = {}
          end
        end
      end
    end
  end
end
