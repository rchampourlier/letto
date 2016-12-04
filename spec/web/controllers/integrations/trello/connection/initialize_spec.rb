require 'spec_helper'
require_relative '../../../../../../apps/web/controllers/integrations/trello/connection/initialize'

describe Web::Controllers::Integrations::Trello::Connection::Initialize do
  let(:action) { Web::Controllers::Integrations::Trello::Connection::Initialize.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
  end
end
