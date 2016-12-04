# frozen_string_literal: true
module Web::Controllers
  module Integrations
    module Trello
      module Connection

        # Callback for Trello integration OAuth connection
        class Callback
          include Web::Action
          include SharedMethods
          include Letto.injection('oauth_consumer_class')
          include Letto.injection('oauth_request_token_class')

          def call(params)
            token, secret = retrieve_access_token(params)
            TrelloConnectionWasSuccessful.call(
              user_uuid: user_uuid,
              access_token: token,
              access_token_secret: secret
            )
            redirect_to routes.root_path
          end

          private

          # From the callback, we fetch the OAuth access token. We retrieve the
          # request token and secret we saved in the session (aka store), rebuild
          # an `Oauth::RequestToken` instance and get the access token.
          def retrieve_access_token(params)
            request_token = oauth_request_token_class.new(consumer, store[:request_token], store[:request_token_secret])
            fetched_access_token = request_token.get_access_token oauth_verifier: params[:oauth_verifier]
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
