# frozen_string_literal: true

require 'dry-struct'
require 'dry/system/container'
require_relative './ext/service'

# Top-level application domain
module Letto
  LOGGER = Logger.new(STDOUT)

  # A dry-system container to provide dependency-injection
  # for external dependencies.
  class Container < Dry::System::Container
    configure do |config|
      config.root = Pathname('./lib')
    end
  end

  # To register a dependency:
  #     Letto.register('some.path', SomeObject)
  def self.register(path, object)
    Container.register(path, object)
  end

  # To access an injected dependency:
  #
  #     Letto.dep('some.path')
  def self.dep(path)
    Container[path]
  end

  # To inject a registered dependency:
  #
  #   include Letto.injection('some.path')
  def self.injection(path)
    Container.injector[path]
  end

  Event = Class.new(Service)
  Event.log_with(LOGGER)
  Event.logging_enabled = false if ENV['HANAMI_ENV'] == 'test'

  Container.finalize!
end

# Inject dependencies
require_relative './dependencies.common'
require_relative "./dependencies.#{ENV['HANAMI_ENV']}"

# Load domain code
Hanami::Utils.require!("#{__dir__}/letto")
