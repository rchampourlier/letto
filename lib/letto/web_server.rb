# frozen_string_literal: true
require "sinatra/base"
require "sinatra/namespace"
require "sinatra_auth/trello"
require "trello"
require "data/user_repository"

HOST = ENV["HOST"]

module Letto

  # Web app module providing web endpoints:
  #   - root (/) with status JSON response,
  #   - webhooks.
  #
  # Webhooks are defined in /triggers/webhooks.
  #
  # TECHNICAL-DEBT: using default cookie-sessions is a vulnerability
  #   since the session will contain OAuth tokens. They should be
  #   stored in a more secure place.
  class WebServer < Sinatra::Base
    register Sinatra::Namespace
    use Rack::Session::Cookie,
      key: "rack.session",
      path: "/",
      secret: ENV["SESSION_SECRET"]

    set :show_exceptions, false if ENV["RACK_ENV"] == "test"

    before do
      session[:uuid] ||= SecureRandom.uuid
      @consumer = SinatraAuth::Trello.consumer(
        ENV["TRELLO_CONSUMER_KEY"],
        ENV["TRELLO_CONSUMER_SECRET"],
        "Letto"
      )
      @user = Letto::Data::UserRepository.find_user(session[:uuid])
      if !session[:oauth][:request_token].nil? && !session[:oauth][:request_token_secret].nil?
        @request_token = OAuth::RequestToken.new(@consumer, session[:oauth][:request_token], session[:oauth][:request_token_secret])
      end

      if !session[:oauth][:access_token].nil? && !session[:oauth][:access_token_secret].nil?
        @access_token = OAuth::AccessToken.new(@consumer, session[:oauth][:access_token], session[:oauth][:access_token_secret])
      end
    end

    get "/auth" do
      if @access_token
        erb :auth_connected
      else
        erb :auth_not_connected
      end
    end

    get "/auth/request" do
      @request_token = @consumer.get_request_token(oauth_callback: "#{HOST}/auth/callback")
      session[:oauth][:request_token] = @request_token.token
      session[:oauth][:request_token_secret] = @request_token.secret
      authorize_url = @request_token.authorize_url + "&name=Letto"
      redirect authorize_url
    end

    get "/auth/callback" do
      @access_token = @request_token.get_access_token oauth_verifier: params[:oauth_verifier]
      session[:oauth][:access_token] = @access_token.token
      session[:oauth][:access_token_secret] = @access_token.secret
      redirect "/auth"
    end

    get "/auth/logout" do
      session[:oauth] = {}
      redirect "/auth"
    end

    get "/trello" do
      Trello.configure do |config|
        config.developer_public_key = ENV["TRELLO_CONSUMER_KEY"]
        config.member_token = session[:oauth][:access_token]
      end
      me = Trello::Member.find("me")
    end

    get "/" do
      { status: "ok" }.to_json
    end

    # Extends the Letto::Web Sinatra app to handle webhook endpoints. These are defined in /triggers/webhooks.
    get "/webhook" do
      handle_webhook(request)
    end

    post "/webhook" do
      handle_webhook(request)
    end

    def handle_webhook(request)
      webhook_value = Letto::ValueObjects::Webhook.with_request(request)
      { status: "ok" }.to_json
    end
  end
end
