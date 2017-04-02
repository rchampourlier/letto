# frozen_string_literal: true
require 'spec_helper'
require_relative '../../../../../../apps/web/controllers/integrations/trello/connection/initialize'

describe Web::Controllers::Integrations::Trello::Connection::Initialize do
  let(:action) do
    Web::Controllers::Integrations::Trello::Connection::Initialize.new
  end
  let(:params) { Hash[] }

  it 'redirects to the authorize URL' do
    response = action.call(params)
    response[0].must_equal 302 # redirect
    response[1]['Location'].must_equal OAuthConsumerMock::RequestToken.new(nil).authorize_url({})
  end
end
