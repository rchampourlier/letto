# frozen_string_literal: true
module Web::Controllers
  module Integrations
    module Trello
      module Connection

        # Callback for Trello integration OAuth connection
        class Callback
          include Web::Action

          def initialize(
            event_successful: TrelloConnectionWasSuccessful,
            oauth_consumer: Connection.oauth_consumer,
            oauth_request_token_class: Letto.dep('oauth_request_token_class')
          )
            @event_successful = event_successful
            @oauth_consumer = oauth_consumer
            @oauth_request_token_class = oauth_request_token_class
          end

          def call(params)
            token, secret = retrieve_access_token(params)
            @event_successful.call(
              user_uuid: session[:user_uuid] || SecureRandom.uuid,
              access_token: token,
              access_token_secret: secret
            )
            redirect_to routes.root_path
          end

          private

          # From the callback, we fetch the OAuth access token. We retrieve the
          # request token and secret we saved in the session, rebuild
          # an `Oauth::RequestToken` instance and get the access token.
          def retrieve_access_token(params)
            request_token = @oauth_request_token_class.new(
              @oauth_consumer,
              session[:integrations][:trello][:request_token],
              session[:integrations][:trello][:request_token_secret]
            )
            fetched_access_token = request_token.get_access_token(
              oauth_verifier: params[:oauth_verifier]
            )
            clean_session
            [fetched_access_token.token, fetched_access_token.secret]
          end

          def request_token
            @request_token ||= @oauth_request_token_class.new(
              consumer,
              session[:request_token],
              session[:request_token_secret]
            )
          end

          def clean_session
            session[:request_token]
          end
        end
      end
    end
  end
end
