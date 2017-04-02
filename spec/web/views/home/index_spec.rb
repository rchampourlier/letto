# frozen_string_literal: true
require 'minitest/autorun'
require_relative '../../../../apps/web/views/home/index'

describe Web::Views::Home::Index do
  let(:exposures) { Hash[connected_to_trello: true] }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/home/index.html.erb') }
  let(:view)      { Web::Views::Home::Index.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #connected_to_trello' do
    view.connected_to_trello.must_equal exposures.fetch(:connected_to_trello)
  end
end
