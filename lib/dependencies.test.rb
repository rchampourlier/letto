# frozen_string_literal: true
require_relative '../spec/support/helpers'

# Mock for OAuth::Consumer
class OAuthConsumerMock
  include Helpers

  # RequestToken mock
  class RequestToken
    def initialize(_oauth_callback); end

    def token
      'token'
    end

    def secret
      'secret'
    end

    def authorize_url(_params)
      "authorize_url?params=params"
    end
  end

  def initialize(*); end

  def get_request_token(oauth_callback:)
    RequestToken.new(oauth_callback)
  end
end

# Mock for OAuth::RequestToken
class OAuthRequestTokenMock

end
Letto.register('oauth_consumer_class', OAuthConsumerMock)
Letto.register('oauth_request_token_class', OAuthRequestTokenMock)
