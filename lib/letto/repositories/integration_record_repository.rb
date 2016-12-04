# Repository for 'integration_records'
class IntegrationRecordRepository < Hanami::Repository

  def create_or_update(data)
    record = integration_records.where(
      user_uuid: data[:user_uuid]
    ).first
    if record
      update(record.id, data)
    else
      create(data)
    end
  end
end
