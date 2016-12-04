# frozen_string_literal: true
module SpecHelpers

  # A set of helpers for feature specs.
  module Features
    def given_i_am_an_user
      @user_uuid = Letto::Persistence::UserRepository.create(
        username: "test-user",
        trello_access_token: "test-access-token",
        trello_access_token_secret: "test-access-token-secret",
        session_id: "test-session-id"
      )
    end

    def given_i_am_logged_in
      Sinatra::Sessionography.session = { session_id: "test-session-id" }
    end

    def given_there_are_no_workflows
      Letto::Persistence::WorkflowRepository.delete_where(true)
    end

    def given_there_are_no_users
      Letto::Persistence::UserRepository.delete_where(true)
    end

    def given_there_are_workflows_for_user(count: 1, user_uuid:)
      count.times.each do |i|
        Letto::Persistence::WorkflowRepository.create(
          user_uuid: user_uuid,
          data: JSON.dump(name: "workflow ##{i}")
        )
      end
    end

    def given_i_fill_in_workflow(workflow)
      page.fill_in "workflow_data", with: workflow
    end

    def when_i_submit_new_workflow_form
      page.click_button("Save as new workflow")
    end

    def it_displays_an_empty_list_of_workflows
      expect(page).to have_content("No workflows, click \"Add workflow\" to add one")
    end

    def it_displays_the_new_workflow_button
      expect(page).to have_button("Add workflow")
    end

    def it_displays_the_list_of_workflows(count: nil)
      expect(page).to have_selector(".workflows_list--row", count: count)
    end

    def it_does_not_display_an_error
      if page.has_selector?(".alert-danger")
        alert = page.find(".alert-danger")
        puts "-- Error message: #{alert.text}" if alert
      end
      expect(page).not_to have_selector(".alert-danger")
    end

    def it_displays_an_error(message)
      within ".alert-danger" do
        expect(page).to have_content(message)
      end
    end

    def it_displays_the_workflow_in_the_list(name:)
      within ".workflows_list--row" do
        expect(page).to have_content(name)
      end
    end
  end
end
