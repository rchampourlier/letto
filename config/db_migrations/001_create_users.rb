#!/usr/bin/env ruby
# frozen_string_literal: true

Sequel.migration do
  up do
    create_table :users do
      String :uuid, primary_key: true
      String :oauth_token
      String :oauth_token_secret
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end

  down do
    drop_table(:users)
  end
end
