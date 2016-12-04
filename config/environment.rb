# frozen_string_literal: true
require 'bundler/setup'
require 'hanami/setup'
require 'hanami/model'
require_relative '../lib/letto'
require_relative '../apps/webhooks/application'
require_relative '../apps/web/application'

Hanami.configure do
  mount Webhooks::Application, at: '/webhooks'
  mount Web::Application, at: '/'

  model do
    ##
    # Database adapter
    #
    # Available options:
    #
    #  * SQL adapter
    #    adapter :sql, 'sqlite://db/letto_development.sqlite3'
    #    adapter :sql, 'postgres://localhost/letto_development'
    #    adapter :sql, 'mysql://localhost/letto_development'
    #
    adapter :sql, ENV['DATABASE_URL']

    ##
    # Migrations
    #
    migrations 'db/migrations'
    schema     'db/schema.sql'
  end

  mailer do
    root 'lib/letto/mailers'

    # See http://hanamirb.org/guides/mailers/delivery
    delivery do
      development :test
      test        :test
      # production :smtp, address: ENV['SMTP_PORT'], port: 1025
    end
  end
end
