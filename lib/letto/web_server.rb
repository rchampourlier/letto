# frozen_string_literal: true
require "sinatra/base"
require "sinatra/namespace"
require "sinatra/flash"
require "trello_auth"
require "data/user_repository"
require "data/workflow_repository"
require "values/webhook"
require "trello_client"
require "runner"
require "users_webhooks_cache"

module Letto
  TRELLO_AUTH_CALLBACK_URL = "#{ENV['HOST']}/connection/callback"
  INCOMING_WEBHOOK_URL = "#{ENV['HOST']}/incoming_webhook"

  # Web server application, providing endpoints
  # for both the user interface, the OAuth callbacks
  # and the incoming webhooks.
  class WebServer < Sinatra::Base
    register Sinatra::Namespace
    register Sinatra::Flash
    use Rack::Session::Cookie,
      key: "rack.session",
      path: "/",
      secret: ENV["SESSION_SECRET"]

    set :show_exceptions, false if ENV["RACK_ENV"] == "test"
    UsersWebhooksCache.load(webhook_url_root: INCOMING_WEBHOOK_URL)

    attr_reader :trello_auth, :user

    before do
      @trello_auth = TrelloAuth.new(session, TRELLO_AUTH_CALLBACK_URL)
      @user = Data::UserRepository.for_session_id(session[:session_id])
    end

    def trello_client_for_current_user
      trello_access_token = user[:trello_access_token]
      trello_access_token_secret = user[:trello_access_token_secret]
      raise "No trello_access_token for current user" if trello_access_token.nil? || trello_access_token_secret.nil?
      @trello_client_for_current_user ||= trello_client(trello_access_token, trello_access_token_secret)
    end

    def trello_client(access_token, access_token_secret)
      TrelloClient.new(access_token, access_token_secret)
    end

    get "/connection" do
      redirect trello_auth.authorize_url
    end

    get "/connection/callback" do
      trello_access_token, trello_access_token_secret = trello_auth.retrieve_access_token(params)
      username = trello_client(trello_access_token, trello_access_token_secret).username
      if user
        Data::UserRepository.update_by_uuid(
          user[:uuid],
          trello_access_token: trello_access_token,
          trello_access_token_secret: trello_access_token_secret
        )
      else
        Data::UserRepository.create(
          username,
          trello_access_token,
          trello_access_token_secret,
          session["session_id"]
        )
      end
      redirect "/"
    end

    get "/connection/destroy" do
      trello_client_for_current_user.delete_token(user[:trello_access_token])
      Data::UserRepository.update_by_uuid(user[:uuid], trello_access_token: nil, trello_access_token_secret: nil)
      redirect "/"
    end

    get "/" do
      @username = @user[:username] if @user
      erb :home
    end

    namespace "/workflows" do

      # INDEX, NEW
      get "" do
        render_workflows(nil, nil)
      end

      # SHOW, EDIT
      get "/:uuid" do
        selected_workflow = Data::WorkflowRepository.for_uuid(params[:uuid])
        content = JSON.pretty_generate(JSON.parse(selected_workflow[:content]))
        selected_uuid = selected_workflow[:uuid]
        render_workflows(content, selected_uuid)
      end

      # CREATE
      post "" do
        create_or_update_workflow(params)
      end

      # UPDATE
      put "/:uuid" do
        create_or_update_workflow(params)
      end

      # DELETE
      delete "/:uuid" do
        uuid = params[:uuid]
        Data::WorkflowRepository.delete_by_uuid(uuid)
        redirect("/workflows")
      end
    end

    namespace "/trello" do
      get "/boards" do
        organizations = trello_client_for_current_user.organizations.map(&:attributes)
        organizations.push(display_name: "No Team", id: nil)
        all_boards = trello_client_for_current_user.boards.map(&:attributes)
        boards = all_boards.select { |board| board[:closed] == false }
        @organizations = boards.each_with_object({}) do |board, hash|
          organization_id = board[:organization_id]
          matching_organization = organizations.find { |organization| organization[:id] == organization_id }
          hash[organization_id] ||= {
            display_name: matching_organization ? matching_organization[:display_name] : organization_id,
            boards: []
          }
          create_webhook_url = "/trello/boards/#{board[:id]}/create_webhook?board_name=#{board[:name]}"
          hash[organization_id][:boards].push([board, create_webhook_url])
        end
        erb :trello_boards
      end

      get "/boards/:board_id/create_webhook" do
        board_id = params[:board_id]
        board_name = params[:board_name]
        description = "Trello webhook on board \"#{board_name}\""
        trello_webhook_id = trello_client_for_current_user.create_board_webhook(
          board_id,
          INCOMING_WEBHOOK_URL,
          description
        )
        UsersWebhooksCache.add_callback_to_cache(
          trello_webhook_id,
          user[:trello_access_token],
          user[:trello_access_token_secret]
        )
        redirect "/trello/webhooks"
      end

      get "/webhooks/delete_webhook/:webhook_id" do
        webhook_id = params[:webhook_id]
        trello_client_for_current_user.delete_webhook(
          webhook_id
        )
        redirect "/trello/webhooks"
      end

      get "/webhooks" do
        @webhooks = trello_client_for_current_user.webhooks.map(&:attributes)
        @delete_webhook_urls = @webhooks.map do |webhooks|
          "/trello/webhooks/delete_webhook/#{webhooks[:id]}"
        end
        erb :trello_webhooks
      end
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

    def handle_incoming_webhook(webhook_id, request)
      webhook = Letto::Values::Webhook.with_request(webhook_id, request)
      Runner.new(config, UsersWebhooksCache).handle_webhook(webhook)
      { status: "ok" }.to_json
    end

    def config
      workflows = Data::WorkflowRepository.all
      config = {}
      config["workflows"] = workflows.map do |workflow|
        parsed_workflow = JSON.parse(workflow[:content])
        parsed_workflow["uuid"] = workflow[:uuid]
        parsed_workflow
      end
      config
    end

    def render_workflows(content, uuid, flash_messages = nil)
      flash_messages&.each { |k, v| flash.now[k] = v }
      @workflows = Data::WorkflowRepository.all
      @content = content
      @selected_uuid = uuid
      erb :workflows
    end

    def create_or_update_workflow(params)
      begin
        parsed_content = JSON.parse(params["content"])
        WorkflowsChecker.check_workflow!(parsed_content)
        uuid = params[:uuid]
        if uuid
          Data::WorkflowRepository.update_by_uuid(uuid, content: JSON.dump(parsed_content))
        else
          uuid = Data::WorkflowRepository.create(JSON.dump(parsed_content))
        end
        successful = true
      rescue JSON::ParserError => e
        err_message = "Invalid JSON: #{e.message}"
        content = params["content"]
      rescue WorkflowsChecker::Error => e
        err_message = "Invalid JSON content: #{e.message}"
        content = JSON.pretty_generate(parsed_content)
      end
      if successful
        flash[:success] = "Workflow #{parsed_content['name']} saved with id #{uuid}"
        redirect "/workflows/#{uuid}"
      else
        render_workflows(content, nil, danger: err_message)
      end
    end
  end
end
