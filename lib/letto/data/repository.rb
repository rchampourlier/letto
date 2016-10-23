# frozen_string_literal: true
require "data/db"
require "active_support/inflector"
module Letto
  module Data

    # Superclass for repositories. Simply provide some shared
    # methods.
    class Repository

      def self.generate_uuid
        SecureRandom.uuid
      end

      def self.db
        Db::CLIENT
      end

      def self.row(data, time = nil)
        time ||= Time.now
        data.merge(
          created_at: time,
          updated_at: time
        )
      end

      def self.insert(data)
        table.insert row(data)
      end

      def self.delete(where_data)
        table.where(where_data).delete
      end

      def self.update_where(values, where_data)
        table.where(where_data).update(values)
      end

      def self.first_where(where_data)
        table.where(where_data).first
      end

      def self.all
        table
      end

      def self.table
        repository_resource = name.split("::").last.gsub(/Repository\Z/, "")
        db[repository_resource.pluralize.underscore.to_sym]
      end

      def self.index
        table.entries
      end
    end
  end
end
