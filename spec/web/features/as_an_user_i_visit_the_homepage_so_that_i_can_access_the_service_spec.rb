# frozen_string_literal: true
# spec/web/features/as_an_user_i_visit_the_homepage_so_that_i_can_access_the_service_spec.rb
require 'features_helper'

describe 'As an user I visit the homepage so that I can access the service' do

  it 'displays an invitation to connect' do
    visit('/')
    page.body.must_include('You must connect:')
  end
end
