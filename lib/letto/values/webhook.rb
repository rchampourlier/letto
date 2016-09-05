# frozen_string_literal: true
module Letto
  module Values

    # A value class to hold webhook request data.
    #
    # Extracts headers from `request.env` (by ignoring keys prefixed by downcase
    # strings).
    class Webhook
      attr_reader :body
      attr_reader :headers

      def self.with_request(id, request)
        new id, extract_headers(request), extract_body(request)
      end

      def initialize(id, headers, body)
        @id = id
        @headers = headers
        @body = body
      end

      def parsed_body
        body.empty? ? { error: "no body" } : JSON.parse(body)
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
        "<Letto::Values::Webhook> #{{ headers: headers, body: body }.to_s}"
      end
    end
  end
end
