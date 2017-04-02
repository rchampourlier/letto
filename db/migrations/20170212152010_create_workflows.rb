# frozen_string_literal: true
Hanami::Model.migration do
  up do
    create_table :workflows do
      primary_key :id
      column :user_uuid, 'uuid', null: false
      column :data, String, null: false
      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end

  down do
    drop_table :workflows
  end
end
