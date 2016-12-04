# frozen_string_literal: true
require "logger"
require "active_support/all"
require "sinatra/base"

# Top-level module
module Letto
  HOST = ENV["HOST"]
  VERSION = File.read(File.expand_path("../../VERSION", __FILE__)).strip
  LOGGER = Logger.new(STDOUT)
  LOGGER.level = Logger::INFO

  AVAILABLE_CORE_MODULES = %i(
    incoming_webhooks
    integrations
    persistence
    web_interface
    workflows
  ).freeze

  CONFIG = {
    modules: AVAILABLE_CORE_MODULES,
    enabled_integrations: %i(trello),
    web: {
      web_interface: "/",
      incoming_webhooks: "/incoming_webhooks"
    }
  }.freeze

  # Start the Letto components.
  # @param config [Hash]: defines which components must be started
  # @param rack_builder [?]: the rackup context on which to call `run`
  #   to start the Sinatra application (`self` from the config.ru script)
  def self.start(config: CONFIG, rack_builder:)
    config[:modules].each do |module_name|
      mod = get_module(module_name)
      mod.start(config: config)
    end
    config[:web].each do |web_module, mount_path|
      mod = get_module(web_module)
      unless mod.is_a?(Class) && mod.superclass == Sinatra::Base
        raise "Module `#{module_name}` is not a Sinatra application."
      end
      rack_builder.map(mount_path) do
        if defined?(mod.rack_middlewares) == :method
          mod.rack_middlewares.each do |middleware|
            use(middleware)
          end
        end
        puts "run(#{mod})"
        run(mod)
      end
    end
  end

  # TODO: protect against access to unexpected modules
  def self.get_module(module_name)
    require "letto/#{module_name}"
    const_get(module_name.to_s.camelize)
  end

  # Helpers for Letto's core modules, easing the integration of core
  # modules in the different components of Letto (e.g. WebInterface).
  module CoreModule

    # By default, a core module does nothing when started.
    # Override if specific actions are required to start.
    def start(config:)
      after_start(config: config) if defined?(after_start) == "method"
    end

    def web_interface_module
      require "#{name.underscore}/web_interface"
      const_get(:WebInterface)
    rescue LoadError, NameError
      nil
    end

    def web_interface_helpers_module
      web_interface_module&.const_get(:Helpers)
    end

    def web_interface?
      web_interface_module != nil
    end

    def start_web_interface(app:)
      web_interface_module.registered(app)
    end
  end
end
