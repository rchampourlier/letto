# frozen_string_literal: true
require "persistence"
require "active_support/inflector"
module Letto
  module Persistence

    # Superclass for repositories. Simply provide some shared
    # methods.
    class Repository

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

      def self.delete_where(where_data)
        where(where_data).delete
      end

      def self.update_where(where_data, values)
        where(where_data).update(values)
      end

      def self.first_where(where_data)
        where(where_data).first
      end

      def self.where(where_data)
        table.where(where_data)
      end

      def self.count
        table.count
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

      def self.db
        Persistence.db
      end
    end
  end
end
