# frozen_string_literal: true
require 'spec_helper'
require_relative '../../../../../../apps/web/controllers/integrations/trello/connection/callback'

describe Web::Controllers::Integrations::Trello::Connection::Callback do
  include Helpers

  let(:action) do
    Web::Controllers::Integrations::Trello::Connection::Callback.new(
      event_successful: event_successful
    )
  end
  let(:params) do
    {
      'rack.session' => {
        integrations: {
          trello: {
            request_token: 'rt',
            request_token_secret: 'rts'
          }
        }
      }
    }
  end
  let(:event_successful) { Minitest::Mock.new }

  it 'is successful' do
    event_successful.expect(:call, true) { true }
    response = action.call(params)
    response[0].must_equal 302
    event_successful.verify
  end

  it 'calls `event_successful`' do
    event_successful.expect(:call, true) do |params|
      params[:access_token].must_equal('token')
      params[:access_token_secret].must_equal('secret')
    end
    action.call(params)
    event_successful.verify
  end

  describe 'user is signed in' do
    before { params['rack.session'][:user_uuid] = 'user-uuid' }

    it 'calls `event_successful` with the user\'s UUID' do
      event_successful.expect(:call, true) do |params|
        params[:user_uuid].must_equal('user-uuid')
      end
      action.call(params)
      event_successful.verify
    end
  end
end
