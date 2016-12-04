require 'spec_helper'
require_relative '../../../../../../apps/web/controllers/integrations/trello/connection/destroy'

describe Web::Controllers::Integrations::Trello::Connection::Destroy do
  let(:action) { Web::Controllers::Integrations::Trello::Connection::Destroy.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
  end
end
