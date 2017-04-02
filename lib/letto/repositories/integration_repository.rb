# frozen_string_literal: true
# Repository for 'integrations'
class IntegrationRepository < Hanami::Repository

  # @param type [String]: the type of integration
  # @param user_uuid [String]: the ID of the user to associate
  #   the integration with
  # @param data [Hash: the data to store for the integration
  def create_or_update(type:, user_uuid:, data:)
    record = find_by_type_and_user_uuid(type, user_uuid)
    if record
      update(record.id, data: data)
    else
      create(
        type: type,
        user_uuid: user_uuid,
        data: data
      )
    end
  end

  def find_by_type_and_user_uuid(type, user_uuid)
    integrations.where(
      type: type,
      user_uuid: user_uuid
    ).first
  end
end
