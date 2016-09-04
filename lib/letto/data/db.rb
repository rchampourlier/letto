# frozen_string_literal: true
require "sequel"

module Letto
  module Data
    module Db
      DATABASE_URL = ENV["DATABASE_URL"]
      CLIENT = Sequel.connect(DATABASE_URL)
      ID_SIZE = 16
    end
  end
end
