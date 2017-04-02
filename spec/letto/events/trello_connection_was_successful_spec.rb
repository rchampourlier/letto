# frozen_string_literal: true
require 'spec_helper'
require 'minitest/mock'
require_relative '../../../lib/letto/events/trello_connection_was_successful'

describe TrelloConnectionWasSuccessful do
  let(:event) { TrelloConnectionWasSuccessful }
  let(:result) { event.call(params_and_injections) }

  class TrelloClientMock
    def initialize(_token, _secret); end

    def username
      'username'
    end
  end

  let(:record) do
    {}
  end

  let(:integration_repository_mock) do
    m = Minitest::Mock.new
    m.expect(:is_a?, false, [Proc])
    m.expect(:create_or_update, record) do |params|
      return false unless params[:user_uuid] == 'user_uuid'
      return false unless params[:data][:username] == 'username'
      true
    end
  end

  let(:params_and_injections) do
    {
      user_uuid: 'user_uuid',
      access_token: 'access_token',
      access_token_secret: 'access_token_secret',
      integration_repository: integration_repository_mock,
      trello_client_class: TrelloClientMock
    }
  end

  it 'creates or updates an integration record' do
    result
    integration_repository_mock.verify
  end
end
