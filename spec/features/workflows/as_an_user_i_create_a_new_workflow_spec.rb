# frozen_string_literal: true
require "spec_helper"

feature "As an user I create a new workflow" do
  before(:all) { given_i_am_an_user }
  after { given_there_are_no_workflows }
  after(:all) { given_there_are_no_users }

  let(:valid_workflow) { workflow.to_json }
  let(:invalid_workflow) { workflow(valid: false).to_json }

  before do
    given_i_am_logged_in
    visit "/workflows"
  end

  scenario "which is valid" do
    given_i_fill_in_workflow(valid_workflow)
    when_i_submit_new_workflow_form
    it_does_not_display_an_error
    it_displays_the_workflow_in_the_list(name: "valid workflow")
    it_displays_the_new_workflow_button
  end

  scenario "which is invalid" do
    given_i_fill_in_workflow(invalid_workflow)
    when_i_submit_new_workflow_form
    it_displays_an_error("a node must have a `type` attribute")
    it_displays_the_new_workflow_button
  end
end
