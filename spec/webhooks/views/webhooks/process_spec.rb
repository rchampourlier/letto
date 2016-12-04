require 'spec_helper'
require_relative '../../../../apps/webhooks/views/webhooks/process'

describe Webhooks::Views::Webhooks::Process do
  let(:exposures) { Hash[foo: 'bar'] }
  let(:template)  { Hanami::View::Template.new('apps/webhooks/templates/webhooks/process.html.erb') }
  let(:view)      { Webhooks::Views::Webhooks::Process.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #foo' do
    skip 'This is an auto-generated test. Edit it and add your own tests.'

    # Example
    view.foo.must_equal exposures.fetch(:foo)
  end
end
