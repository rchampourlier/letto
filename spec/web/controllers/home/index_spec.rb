# frozen_string_literal: true
require 'spec_helper'
require_relative '../../../../apps/web/controllers/home/index'

describe Web::Controllers::Home::Index do
  let(:action) { Web::Controllers::Home::Index.new(injections) }
  let(:params) { { 'rack.session' => session } }
  let(:session) { {} }
  let(:injections) { { integrations: integration_repository } }
  let(:integration_repository) do
    m = Minitest::Mock.new
    m.expect(:find_by_type_and_user_uuid, integration) { |_, _| true }
    m
  end
  let(:integration) { nil }

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
  end

  describe 'user is not connected' do
    # it 'exposes a nil `user_uuid`' do
    #   action.exposures[:user_uuid].must_be_nil
    # end
  end

  describe 'user is connected' do
    let(:session) { { user_uuid: 'user-uuid' } }

    # it 'exposes `user_uuid`' do
    #   action.exposures[:user_uuid].must_equal('user-uuid')
    # end

    describe 'has Trello integration' do
      let(:integration) { Minitest::Mock.new }
      before { integration.expect(:[], 'username') }

      it 'exposes the integration\'s username to `trello_connected_username`' do
        action.exposures.must_equal(trello_connected_username: 'username')
      end
    end

    # describe 'has not Trello integration' do
    #   it 'exposes a nil `trello_username`' do
    #     action.exposures[:trello_connected_username].must_be_nil
    #   end
    # end
  end
end
