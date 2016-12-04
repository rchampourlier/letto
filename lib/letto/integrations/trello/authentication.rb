# frozen_string_literal: true
require "oauth"
require "oauth/consumer"
require "integrations/trello/client"

module Letto
  module Integrations
    module Trello

      # Authentication component for the Trello integration.
      class Authentication
        attr_reader :consumer

        CALLBACK_URL = "#{Letto::HOST}/trello/connection/callback"

        TRELLO_OAUTH_CONFIG = {
          site: "https://trello.com",
          request_token_path: "/1/OAuthGetRequestToken",
          authorize_path: "/1/OAuthAuthorizeToken",
          access_token_path: "/1/OAuthGetAccessToken",
          http_method: :get
        }.freeze

        AUTHORIZE_URL_PARAMS = {
          name: ENV["TRELLO_APP_NAME"] || "Unknown application",
          scope: "read,write"
        }.freeze

        def initialize(session, callback)
          @session = prepare_session(session)
          @consumer ||= OAuth::Consumer.new(
            ENV["TRELLO_CONSUMER_KEY"],
            ENV["TRELLO_CONSUMER_SECRET"],
            TRELLO_OAUTH_CONFIG
          )
          @callback = callback
        end

        # We fetch an OAuth request token and store the token and its secret
        # in the session (aka store). We then return the authorize URL where
        # to redirect to.
        def authorize_url
          request_token = @consumer.get_request_token(oauth_callback: @callback)
          store[:request_token] = request_token.token
          store[:request_token_secret] = request_token.secret
          request_token.authorize_url(AUTHORIZE_URL_PARAMS)
        end

        # From the callback, we fetch the OAuth access token. We retrieve the
        # request token and secret we saved in the session (aka store), rebuild
        # an `Oauth::RequestToken` instance and get the access token.
        def retrieve_access_token(params)
          request_token = OAuth::RequestToken.new(@consumer, store[:request_token], store[:request_token_secret])
          fetched_access_token = request_token.get_access_token oauth_verifier: params[:oauth_verifier]
          clean_session
          [fetched_access_token.token, fetched_access_token.secret]
        end

        private

        def prepare_session(session)
          session[:oauth] ||= {}
          session[:oauth][:trello] ||= {}
          session
        end

        def clean_session
          @session[:oauth][:trello] = nil
        end

        def store
          @session[:oauth][:trello]
        end

        # Include the routes for Trello::Authentication in the
        # top-level application using
        # `register Letto::Integrations::Trello::Authentication::Routes`
        module Routes

          def self.registered(app)

            app.get "/connection" do
              auth = Authentication.new(session, CALLBACK_URL)
              redirect auth.authorize_url
            end

            app.get "/connection/callback" do
              auth = Authentication.new(session, CALLBACK_URL)
              trello_access_token, trello_access_token_secret = auth.retrieve_access_token(params)
              username = Client.new(trello_access_token, trello_access_token_secret).username
              user = Persistence::UserRepository.for_session_id(session[:session_id])
              if user
                Persistence::UserRepository.update_by_uuid(
                  uuid: user[:uuid],
                  trello_access_token: trello_access_token,
                  trello_access_token_secret: trello_access_token_secret
                )
              else
                Persistence::UserRepository.create(
                  username: username,
                  trello_access_token: trello_access_token,
                  trello_access_token_secret: trello_access_token_secret,
                  session_id: session["session_id"]
                )
              end
              redirect "/"
            end

            app.get "/connection/destroy" do
              Trello.client(user: user).delete_token(user[:trello_access_token])
              Persistence::UserRepository.update_by_uuid(
                uuid: user[:uuid],
                trello_access_token: nil,
                trello_access_token_secret: nil,
                force_nil: true
              )
              redirect "/"
            end
          end
        end
      end
    end
  end
end
