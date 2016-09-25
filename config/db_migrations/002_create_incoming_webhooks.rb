#!/usr/bin/env ruby
# frozen_string_literal: true

Sequel.migration do
  up do
    create_table :incoming_webhooks do
      String :uuid, primary_key: true
      String :description, null: false
      String :remote_id
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end

  down do
    drop_table(:webhooks)
  end
end
