# frozen_string_literal: true
require 'minitest/mock'
module Helpers

  # @param options [Hash]: hash representing the way the double should respond.
  #   The key is the name of the method, the value is the returned value.
  #   Currently only supports key => value mapping (no block).
  def double(options)
    # double_class = Struct.new(*options.keys)
    # double_class.new(*options.values)
    m = Minitest::Mock.new
    options.each do |k, v|
      m.expect(k, v) { true }
    end
    m
  end
end
