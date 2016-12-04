# frozen_string_literal: true
module Letto
  module Workflows

    # A value class to hold webhook request data.
    #
    # Extracts headers from `request.env` (by ignoring keys prefixed by downcase
    # strings).
    class WebhookValue
      attr_reader :uuid
      attr_reader :body
      attr_reader :headers

      def self.with_request(uuid:, request:)
        new(uuid, extract_headers(request), extract_body(request))
      end

      def initialize(uuid, headers, body)
        @uuid = uuid
        @headers = headers
        @body = body
      end

      def self.extract_headers(request)
        request.env.reject do |k, _v|
          k =~ /\A[a-w]/
        end
      end

      def self.extract_body(request)
        request.body.rewind
        request.body.read
      end

      def to_s
        "<Letto::Values::Webhook> #{{ headers: headers, body: body }}"
      end
    end
  end
end
