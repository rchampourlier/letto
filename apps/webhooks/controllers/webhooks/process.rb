# frozen_string_literal: true
module Webhooks::Controllers::Webhooks
  class Process
    include Webhooks::Action

    def call(params)
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
      self.body = { status: 'ok' }.to_json
    end
  end
end
