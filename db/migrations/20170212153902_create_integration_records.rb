Hanami::Model.migration do
  up do
    execute 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"'

    create_table :integration_records do
      column :id, 'uuid', null: false, default: Hanami::Model::Sql.function(:uuid_generate_v4)
      column :user_uuid, String, null: false
      column :data, 'jsonb'
      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end

  down do
    drop_table :integration_records
  end
end
