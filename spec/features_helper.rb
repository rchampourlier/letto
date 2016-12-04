# Require this file for feature tests
require_relative './spec_helper'
require_relative './support/fixtures'

require 'capybara'
require 'capybara/dsl'

Capybara.app = Hanami.app

class MiniTest::Spec
  include Capybara::DSL
  include Helpers
end
