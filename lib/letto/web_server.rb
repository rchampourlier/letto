# frozen_string_literal: true
require "sinatra/base"
require "sinatra/namespace"
require "auth"
require "data/user_repository"
require "data/incoming_webhook_repository"
require "values/webhook"
require "trello_client"

module Letto
  AUTH_CALLBACK_URL = "#{ENV['HOST']}/connection/callback"
  INCOMING_WEBHOOK_URL = "#{ENV['HOST']}/incoming_webhook"

  # Web app module providing web endpoints:
  #   - root (/) with status JSON response,
  #   - webhooks.
  #
  # Webhooks are defined in /triggers/webhooks.
  class WebServer < Sinatra::Base
    register Sinatra::Namespace
    use Rack::Session::Cookie,
      key: "rack.session",
      path: "/",
      secret: ENV["SESSION_SECRET"]

    set :show_exceptions, false if ENV["RACK_ENV"] == "test"

    attr_reader :auth

    before do
      @auth = Auth.new(session, AUTH_CALLBACK_URL)
      @user = Data::UserRepository.for_session_id(session[:session_id])
    end

    def trello_client
      @trello_client ||= TrelloClient.new(auth.access_token, auth.access_token_secret)
    end

    get "/connection" do
      redirect auth.authorize_url
    end

    get "/connection/callback" do
      auth.retrieve_access_token(params)
      username = trello_client.username
      Data::UserRepository.create(
        username,
        auth.access_token,
        auth.access_token_secret,
        session["session_id"]
      )
      redirect "/"
    end

    get "/connection/destroy" do
      # TODO
      redirect "/"
    end

    get "/logout" do
      # TODO
    end

    get "/" do
      @username = @user[:username] if @user
      erb :home
    end

    namespace "/trello" do
      get "/boards" do
        @organizations = trello_client.organizations.map(&:attributes)
        all_boards = trello_client.boards.map(&:attributes)
        @boards = all_boards.select { |board| board[:closed] == false }
        @create_webhook_urls = @boards.map do |board|
          "/trello/boards/#{board[:id]}/create_webhook?board_name=#{board[:name]}"
        end
        erb :trello_boards
      end

      get "/boards/:board_id/create_webhook" do
        board_id = params[:board_id]
        board_name = params[:board_name]
        description = "Trello webhook on board \"#{board_name}\""
        trello_webhook_id = trello_client.create_board_webhook(
          board_id,
          INCOMING_WEBHOOK_URL,
          description
        )
        Data::IncomingWebhookRepository.create(description, trello_webhook_id)
        redirect "/trello/webhooks"
      end

      get "/webhooks" do
        @webhooks = trello_client.webhooks.map(&:attributes)
        erb :trello_webhooks
      end
    end

    get "/incoming_webhooks" do
      @incoming_webhooks = Data::IncomingWebhookRepository.index
      erb :incoming_webhooks
    end

    head "/incoming_webhook/:webhook_id" do
      handle_incoming_webhook(params[:webhook_id], request)
    end

    get "/incoming_webhook/:webhook_id" do
      handle_incoming_webhook(params[:webhook_id], request)
    end

    post "/incoming_webhook/:webhook_id" do
      handle_incoming_webhook(params[:webhook_id], request)
    end

    def handle_incoming_webhook(id, request)
      webhook = Letto::Values::Webhook.with_request(id, request)
      puts(webhook)
      { status: "ok" }.to_json
    end
  end
end
