# frozen_string_literal: true
require 'spec_helper'

describe IntegrationRepository do
  before { repository.clear }
  let(:repository) { IntegrationRepository.new }
  let(:integrations) { repository.send(:integrations) }
  let(:user_uuid) { SecureRandom.uuid }
  let(:data) do
    {
      type: 'test',
      user_uuid: user_uuid,
      data: { value: true }
    }
  end

  describe '#create_or_update(type:, user_uuid:, data:)' do

    describe 'already exists' do
      before { repository.create(data) }

      it 'updates the existing record' do
        repository.create_or_update(data.merge(data: { value: false }))
        integrations.count.must_equal(1)
        integrations.order(:created_at).last.dig(:data, 'value').must_equal(false)
      end
    end

    describe 'does not exist' do
      it 'creates a new record' do
        repository.create_or_update(data)
        integrations.count.must_equal(1)
        integrations.order(:created_at).last.dig(:data, 'value').must_equal(true)
      end
    end
  end
end
