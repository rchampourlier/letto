# frozen_string_literal: true
require 'spec_helper'
require_relative '../../../../../../apps/web/controllers/integrations/trello/connection/destroy'

describe Web::Controllers::Integrations::Trello::Connection::Destroy do
  include Helpers
  let(:action) do
    Web::Controllers::Integrations::Trello::Connection::Destroy.new(
      event: event
    )
  end
  let(:params) do
    {
      'rack.session' => {
        user_uuid: 'user-uuid'
      }
    }
  end
  let(:event) { Minitest::Mock.new }

  it 'is successful' do
    event.expect(:call, true, [{ user_uuid: 'user-uuid' }])
    response = action.call(params)
    event.verify
    response[0].must_equal 302 # redirect to /
  end
end
