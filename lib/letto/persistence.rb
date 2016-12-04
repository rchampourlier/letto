# frozen_string_literal: true
require "sequel"

module Letto

  # Top-level data module. Contains Sequel repository classes
  # to interact with the data storage.
  module Persistence
    extend CoreModule

    DATABASE_URL = ENV["DATABASE_URL"]

    def self.start(config:)
      db
    end

    def self.db
      @db || Sequel.connect(DATABASE_URL)
    end
  end
end
