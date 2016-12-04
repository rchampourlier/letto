# frozen_string_literal: true
require "sinatra/base"
require "sinatra/namespace"
require "sinatra/flash"
require "persistence/user_repository"

module Letto

  # The Sinatra application for the web user-interface.
  class WebInterface < Sinatra::Base
    extend CoreModule

    register Sinatra::Namespace
    register Sinatra::Flash
    use Rack::Session::Cookie,
      key: "rack.session",
      path: "/",'Letto::Integrations::Trello::Client',
      secret: ENV["SESSION_SECRET"]

    set :show_exceptions, false if ENV["RACK_ENV"] == "test"

    # The views are organized within module directories. We reference
    # them from the root directory.
    set :views, proc { root }

    module Helpers
      def user
        @user ||= Persistence::UserRepository.for_session_id(session[:session_id])
      end

      def render_view(name)
        module_path = (self.class.name.underscore.split("/") - ["letto"]).join("/")
        erb "#{module_path}/views/#{name}".to_sym
      end
    end
    helpers Helpers

    # Returns the middlewares to be added to the Rack endpoint.
    def self.rack_middlewares
      [Rack::MethodOverride]
    end

    def self.registered(app)
      puts "#{self}.registered"
    end

    def self.after_start(config:)
      config[:modules].each do |module_name|
        next if module_name == :web_interface
        mod = Letto.get_module(module_name)
        next unless mod.web_interface?
        namespace module_name.to_s do |namespace|
          web_interface_module = mod.web_interface_module
          puts "register #{web_interface_module} into namespace #{module_name}"
          namespace.register(web_interface_module)
          if (helpers_module = web_interface_helpers_module)
            namespace.helpers { include helpers_module }
          end
          namespace.helpers { include Helpers }
        end
      end
    end

    get "/" do
      @username = user[:username] if user
      render_view :home
    end
  end
end
