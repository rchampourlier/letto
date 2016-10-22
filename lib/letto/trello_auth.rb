# frozen_string_literal: true
require "oauth"
require "oauth/consumer"
module Letto

  # Handles OAuth1.0a Trello authentication
  class TrelloAuth
    attr_reader :access_token, :access_token_secret

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

    def authorize_url
      request_token = @consumer.get_request_token(oauth_callback: @callback)
      store[:request_token] = request_token.token
      store[:request_token_secret] = request_token.secret
      request_token.authorize_url(AUTHORIZE_URL_PARAMS)
    end

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

  end
end
