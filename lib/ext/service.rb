# frozen_string_literal: true
require 'dry-struct'
require_relative './types'

# A service object class.
#
# It enables you to specify parameters using `Dry::Struct` and
# `Dry::Types` benefits!. Specify a parameter, for example:
#
#     class SomeService < Service
#       param :param_name, Dry::Types::Strict::String
#     end
#
# It also enables you to inject dependencies. Add this line to
# your service's definition:
#
#     inject :dependency, ExternalDependency.new
#
# If you need to defer the evaluation of the dependency, you
# may pass a proc:
#
#     inject :dependency, proc { ExternalDependency.new }
#
# _NB: your param and injection names must not collide!_
#
# When `call`ing or initializing the service, you may specify the
# injected dependency:
#
#     SomeService.call(dependency: proc { OtherService.new })
#
# You may then access the dependency inside your service's code
# using the service name:
#
#     class SomeService < Service
#       def perform_call
#         dependency.call
#       end
#     end
#
# To execute the service, you may:
#
# - call `.call` on the service class: `SomeService.call(params_and_injections)`
# - call `#call` on an instance of the service class:
#   `SomeService.new(params_and_injections).call`
#
# Usage
# =====
#     class SomeService < Service
#       param :some_string_param, Types::Strict::String
#     end
#     SomeService.call(some_string_param: 'TheString')
#     # => Service::Result(...)
#
# Result
# ======
# `#call` will Return a `Result` value object. It has 2 attributes:
#   - `status`: `ok` or `error`. By default, the service will
#     raise an error, so either the status is `ok` or an error
#     was raised.
#   - `return_value`: the return value of the service call,
#     may be any type from Dry::Types (including Nil).
#
# Logging
# =======
# You can disable logging or set a specific logger.
# By default, the logger is a standard Ruby logger logging
# to STDOUT at `Logger::INFO` level.
#
#     SomeService.logging_enabled = false # disable logging
#     SomeService.log_with CustomLogger.new # override logger
#
class Service

  # Value object for the result returned by a service #call.
  #
  class Result < Dry::Struct
    AnyType =
      Types::Nil   | Types::Symbol   | Types::Bool |
      Types::Date  | Types::DateTime | Types::Time |
      Types::Array | Types::Hash
    StatusType = Types::Strict::Symbol.enum(:ok, :error)

    attribute :status, StatusType
    attribute :return_value, AnyType
  end

  def self.call(params_and_injections = nil)
    new(params_and_injections).call
  end

  def initialize(params_and_injections = nil)
    params, init_injections = split_params_and_injections(params_and_injections)
    @params = param_class.new(params)
    apply_injections(init_injections)
  end

  def call
    before_call
    result = perform_call
    after_call
    Result.new(
      status: :ok,
      return_value: result
    )
  end

  def perform_call
    # doing nothing
  end

  def self.param(name, type)
    raise TypeError, 'param name must be a Symbol' unless name.is_a?(Symbol)
    param_class.attribute(name, type)
    class_eval do
      define_method(name) { params.send(name.to_sym) }
    end
  end

  def self.param_class
    @param_class ||= begin
      Class.new(Dry::Struct).tap do |k|
        k.constructor_type :strict
      end
    end
  end

  # We inject using a block so this defers the evaluation of the specified
  # object, which is not necessary if the injection gets overridden when
  # the service is initialized or called.
  def self.inject(name, injection)
    raise(TypeError, 'injection name must be a Symbol') unless name.is_a?(Symbol)
    injections[name] = injection
    class_eval do
      define_method(name) do
        injection = injections[name]
        return injection unless injection.is_a?(Proc)
        injection.call
      end
    end
  end

  def self.injections
    @injections ||= {}
  end

  def self.logging_enabled
    return @logging_enabled unless @logging_enabled.nil?
    @logging_enabled = true
  end

  class << self
    attr_writer :logging_enabled
  end

  def self.log_with(logger)
    @logger = logger
  end

  def self.logger
    @logger ||= begin
      l = Logger.new(STDOUT)
      l.level = Logger::INFO
      l
    end
  end

  private

  attr_reader :params
  attr_accessor :injections

  def before_call
    @time_start = Time.now
  end

  def after_call
    return unless logging?
    logger.info "#{self.class.name} -- took #{Time.now - @time_start}s"
  end

  def param_class
    self.class.param_class
  end

  def split_params_and_injections(params_and_injections)
    return nil if params_and_injections.nil?
    r = params_and_injections.partition do |k, _v|
      !self.class.injections.include?(k)
    end
    r.map { |i| Hash[i] }
  end

  # Apply the specified injections to the object by merging the
  # default values with the specified ones.
  def apply_injections(init_injections)
    self.injections = {}.merge(self.class.injections)
    return if init_injections.nil?
    init_injections.each do |k, v|
      injections[k] = v
    end
  end

  def logger
    self.class.logger
  end

  def logging?
    self.class.logging_enabled
  end
end
