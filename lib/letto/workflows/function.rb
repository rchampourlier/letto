# frozen_string_literal: true
require "active_support/inflector"

module Letto
  module Workflows

    # Namespace module for functions. Provides the `for_name(function_name)`
    # method that returns the appropriate function class for the specified
    # function.
    #
    # TODO: function arguments must be nodes and processed as such
    module Function
      Error = Class.new(StandardError)

      # Base class for functions.
      #
      # Contract
      # ========
      #
      # Subclasses must:
      #   - implement `#run_after(arguments:)` which performs
      #     the operation and returns the result,
      #   - define `EXPECTED_ARGUMENTS`, an array containing the names
      #     of the expected arguments that must be present in the
      #     passed `arguments` hash.
      #
      class Base
        EXPECTED_ARGUMENTS = [].freeze
        ERR_MSG_ARGUMENTS_INVALID = "Function %s expected arguments %s, got %s"

        attr_reader :arguments, :context

        # Runs the function.
        #
        # If the function raises an error, the error is catched and raised
        # again as a `Function::Error`.
        def run(arguments:, context:)
          @arguments = arguments
          @context = context
          ensure_expected_arguments_present!
          run_after

        rescue StandardError => e
          raise_error message: e
        end

        def expected_arguments
          self.class.const_get(:EXPECTED_ARGUMENTS)
        end

        def respond_to_missing?(method_name, include_private = false)
          expected_arguments.include?(method_name.to_s) || super
        end

        def method_missing(method_name, *args, &block)
          return arguments[method_name.to_s] if expected_arguments.include?(method_name.to_s)
          super
        end

        protected

        def raise_error(message:)
          raise(Error, message)
        end

        # By default, simply return the arguments
        def run_after
          arguments
        end

        private

        def ensure_expected_arguments_present!
          return if (arguments.keys - expected_arguments).empty?
          raise(Error, format(ERR_MSG_ARGUMENTS_INVALID, name, expected_arguments, arguments.keys))
        end

        def name
          self.class.name.split("::").last.underscore
        end
      end

      # Example:
      #     Function.for_name(:add)
      #     #=> Function::Add
      def self.for_name(name:)
        const_get(name.to_s.camelize)
      end

      def self.load_functions
        Dir[File.expand_path("../function/*.rb", __FILE__)].each do |file|
          next if file =~ /base.rb/
          require file
        end
      end

      load_functions
    end
  end
end
