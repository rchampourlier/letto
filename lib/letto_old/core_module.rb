# frozen_string_literal: true
module Letto
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
