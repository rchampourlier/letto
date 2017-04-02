# frozen_string_literal: true
Hanami::Model.migration do
  up do
    create_table :integrations do
      primary_key :id
      foreign_key :user_id, :users, on_delete: :cascade, null: false

      column :user_uuid, String, null: false
      column :type, String, null: false
      column :data, 'jsonb'
      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end

  down do
    drop_table :integrations
  end
end
