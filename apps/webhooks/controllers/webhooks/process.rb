# frozen_string_literal: true
require_relative '../../../../lib/letto/events/webhook_received'

module Webhooks::Controllers::Webhooks

  # Process incoming webhook
  class Process
    include Webhooks::Action

    def call(params)
      WebhookReceived.call(
        id: params[:id],
        user_uuid: params[:user_uuid],
        params: params.to_h
      )
      self.body = { status: 'ok' }.to_json
    end
  end
end
