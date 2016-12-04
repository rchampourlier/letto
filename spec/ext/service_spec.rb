# frozen_string_literal: true
require 'spec_helper'
require_relative '../../lib/ext/service'

describe Service do
  class BaseService < Service
    def perform_call
      :called_perform_call
    end
    self.logging_enabled = false
  end
  let(:result) { service.call(params_and_injections) }
  let(:service) { BaseService }
  let(:params_and_injections) { nil }

  describe 'result value object' do
    it 'is an instance of `Service::Result`' do
      result.must_be_instance_of(Service::Result)
    end

    it 'exposes the status of the call' do
      result.status.must_equal(:ok)
    end

    it 'exposes the return value of `#perform_call`' do
      result.return_value.must_equal(:called_perform_call)
    end
  end

  describe 'providing params' do
    class ServiceWithParams < Service
      param :mandatory_string, Types::Strict::String
      param :mandatory_coercible_int, Types::Coercible::Int
      param :optional_coercible_int, Types::Coercible::Int.optional
      self.logging_enabled = false

      def perform_call
        mandatory_string
      end
    end
    let(:service) { ServiceWithParams }
    let(:params_and_injections) do
      {
        mandatory_string: 'string',
        mandatory_coercible_int: '1',
        optional_coercible_int: 1
      }
    end

    it 'can call the param by its name within a service method' do
      result.return_value.must_equal('string')
    end

    describe 'mandatory param missing' do
      let(:params_and_injections) do
        {
          mandatory_coercible_int: 1,
          optional_coercible_int: '1'
        }
      end

      it 'raises an error' do
        proc { result }.must_raise Dry::Struct::Error
      end
    end

    describe 'invalid param' do
      let(:params_and_injections) do
        {
          mandatory_string: 'string',
          mandatory_coercible_int: :symbol,
          optional_coercible_int: 1
        }
      end

      it 'raises an error' do
        proc { result }.must_raise TypeError
      end
    end
  end

  describe 'injecting dependencies' do
    class DefaultDependency
      def call
        :default
      end
    end
    class InjectedDependency
      def call
        :injected
      end
    end
    class ServiceWithInjections < Service
      inject :dependency, DefaultDependency.new
      self.logging_enabled = false
      def perform_call
        dependency.call
      end
    end
    let(:service) { ServiceWithInjections }

    describe 'no injection' do
      it 'uses the default value' do
        result.return_value.must_equal(:default)
      end
    end

    describe 'injected value' do
      let(:params_and_injections) do
        { dependency: InjectedDependency.new }
      end

      it 'uses the injected value when specified' do
        result.return_value.must_equal(:injected)
      end
    end

    describe 'injected as a proc' do
      let(:params_and_injections) do
        { dependency: proc { InjectedDependency.new } }
      end

      it 'uses the injected value when specified' do
        result.return_value.must_equal(:injected)
      end
    end
  end
end
