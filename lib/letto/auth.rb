# frozen_string_literal: true
require "oauth"
require "oauth/consumer"
module Letto

  # Handles OAuth1.0a Trello authentication
  class Auth

    TRELLO_OAUTH_CONFIG = {
      site: "https://trello.com",
      request_token_path: "/1/OAuthGetRequestToken",
      authorize_path: "/1/OAuthAuthorizeToken",
      access_token_path: "/1/OAuthGetAccessToken",
      http_method: :get
    }.freeze

    def initialize(session, callback)
      @session = prepare_session(session)
      @consumer ||= OAuth::Consumer.new(
        ENV["TRELLO_CONSUMER_KEY"],
        ENV["TRELLO_CONSUMER_SECRET"],
        TRELLO_OAUTH_CONFIG
      )
      @callback = callback
      @name = ENV["TRELLO_APP_NAME"] || "Unknown application"

      load_request_token
      load_access_token
    end

    def connected?
      !@access_token.nil?
    end

    def authorize_url
      @request_token = @consumer.get_request_token(oauth_callback: @callback)
      store[:request_token] = @request_token.token
      store[:request_token_secret] = @request_token.secret
      @request_token.authorize_url + "&name=#{@name}"
    end

    def retrieve_access_token(params)
      @access_token = @request_token.get_access_token oauth_verifier: params[:oauth_verifier]
      store[:access_token] = @access_token.token
      store[:access_token_secret] = @access_token.secret
    end

    def access_token
      store[:access_token]
    end

    def access_token_secret
      store[:access_token_secret]
    end

    private

    def prepare_session(session)
      session[:oauth] ||= {}
      session[:oauth][:trello] ||= {}
      session
    end

    def load_request_token
      return unless store_has_request_token?
      @request_token = OAuth::RequestToken.new(@consumer, store[:request_token], store[:request_token_secret])
    end

    def load_access_token
      return unless store_has_access_token?
      @access_token = OAuth::AccessToken.new(@consumer, store[:access_token], store[:access_token_secret])
    end

    def store
      @session[:oauth][:trello]
    end

    def store_has_request_token?
      !store[:request_token].nil? && !store[:request_token_secret].nil?
    end

    def store_has_access_token?
      !store[:access_token].nil? && !store[:access_token_secret].nil?
    end
  end
end
