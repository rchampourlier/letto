# frozen_string_literal: true
require "spec_helper"
require_relative "./helpers"

include SpecHelpers::Trello

feature "Integrations > Trello > As an user I display the list of webhooks" do
  before(:all) { given_i_am_an_user }
  before { given_i_am_logged_in }
  after(:all) { given_there_are_no_users }

  scenario "when there are webhooks to display" do
    given_the_trello_client_responds_with_webhooks(count: 1)
    visit("/trello/webhooks")
    it_displays_the_list_of_webhooks(count: 1)
  end
end
