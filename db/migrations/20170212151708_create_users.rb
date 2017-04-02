# frozen_string_literal: true
Hanami::Model.migration do
  up do
    create_table :users do
      primary_key :id
      column :username, String, null: false
      column :session_id, String
      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end

  down do
    drop_table :users
  end
end
