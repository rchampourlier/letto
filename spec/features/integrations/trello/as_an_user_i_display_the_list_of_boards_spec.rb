# frozen_string_literal: true
require "spec_helper"

feature "Integrations > Trello > As an user I display the list of boards" do
  before(:all) { given_i_am_an_user }
  before { given_i_am_logged_in }
  after(:all) { given_there_are_no_users }

  scenario "when there are boards to display" do
    given_the_trello_client_responds_with_boards(open: 1, closed: 1)
    visit("/trello/boards")
    it_displays_the_list_of_boards(count: 1)
  end
end
