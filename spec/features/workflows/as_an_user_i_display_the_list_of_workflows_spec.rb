# frozen_string_literal: true
require "spec_helper"

feature "As an user I display the list of workflows" do
  before(:all) { given_i_am_an_user }
  before { given_i_am_logged_in }
  after { given_there_are_no_workflows }
  after(:all) { given_there_are_no_users }

  scenario "with no workflows" do
    given_there_are_workflows_for_user(user_uuid: "some-user-uuid")
    visit "/workflows"
    it_displays_an_empty_list_of_workflows
    it_displays_the_new_workflow_button
  end

  scenario "with 2 workflows" do
    given_there_are_workflows_for_user(user_uuid: @user_uuid, count: 2)
    visit "/workflows"
    it_displays_the_list_of_workflows(count: 2)
    it_displays_the_new_workflow_button
  end
end
