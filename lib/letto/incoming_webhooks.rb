# frozen_string_literal: true
require "sinatra/base"
require "sinatra/namespace"
require "sinatra/flash"
require "letto/incoming_webhooks/webhook_value"

module Letto

  # Handle incoming webhooks from external sources.
  #
  # The handling of incoming webhooks is not delegated to `Integrations`
  # modules. Rather, it's centralized in this `IncomingWebhooks` module
  # to provide an unique infrastructure to receive, log, monitor and
  # process incoming webhooks. `Integrations` modules will be notified of an
  # incoming webhook by listening to the `:received_webhook` event on the
  # global event bus (`EventTrain`).
  class IncomingWebhooks < Sinatra::Base
    extend CoreModule

    module Helpers
      def handle_incoming_webhook(user_uuid:, webhook_uuid:, request:)
        webhook = WebhookValue.with_request(
          uuid: webhook_uuid,
          request: request
        )
        EventTrain.publish(
          event_name: :received_webhook,
          event_data: {
            user_uuid: user_uuid,
            webhook_uuid: webhook.uuid,
            webhook_headers: webhook.headers,
            webhook_body: webhook.body
          }
        )
        { status: "ok" }.to_json
      end
    end
    helpers Helpers

    # Returns the appropriate URL for a new incoming webhook with the
    # specified parameters. Except for an event published on the event
    # bus, nothing else is done (no persistance of the created webhook
    # in anyway - not necessary for now).
    # TODO: move to WebInterface module
    def create(integration:, user_uuid:, context:)
      params = {
        integration: integration,
        user_uuid: user_uuid,
        context: context
      }
      url = webhook_url(params)
      EventTrain.publish(event_name: :created_webhook, event_data: { webhook_url: url })
      url
    end

    URL_BASE = "#{Letto::HOST}/incoming_webhooks"

    # @param integration: [String] name of the integration for which the
    #   webhook is defined
    # @param user_uuid: [String]
    # @param context: [Hash] ignored for now
    def webhook_url(integration:, user_uuid:, _context:)
      "#{URL_BASE}/user/#{user_uuid}/#{integration}"
    end

    %i(head get post).each do |verb|
      send(verb, "/incoming_webhook/:user_uuid/:webhook_uuid") do
        IncomingWebhooks.new.handle_incoming_webhook(
          user_uuid: params[:user_uuid],
          webhook_uuid: params[:webhook_uuid],
          request: request
        )
      end
    end
  end
end
