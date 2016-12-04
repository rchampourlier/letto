Hanami::Model.migration do
  up do
    execute 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"'

    create_table :workflows do
      column :id, 'uuid', null: false, default: Hanami::Model::Sql.function(:uuid_generate_v4)
      column :user_uuid, String, null: false
      column :data, String, null: false
      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end

  down do
    drop_table :workflows
    execute 'DROP EXTENSION IF EXISTS "uuid-ossp"'
  end
end
