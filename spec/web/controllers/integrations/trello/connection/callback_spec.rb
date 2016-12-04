require 'spec_helper'
require_relative '../../../../../../apps/web/controllers/integrations/trello/connection/callback'

describe Web::Controllers::Integrations::Trello::Connection::Callback do
  let(:action) { Web::Controllers::Integrations::Trello::Connection::Callback.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
  end
end
