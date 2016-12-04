require 'spec_helper'
require_relative '../../../../apps/webhooks/controllers/webhooks/process'

describe Webhooks::Controllers::Webhooks::Process do
  let(:action) { Webhooks::Controllers::Webhooks::Process.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
  end
end
