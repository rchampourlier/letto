# frozen_string_literal: true
require "spec_helper"

feature "Integrations > Trello > As an user I connect through Trello" do

  scenario "displays a link to connect through Trello" do
    visit("/")
    expect(page).to have_content("connect through Trello")
  end

  context "I click the Trello connection link on the homepage" do
    scenario "redirection to authorize URL" do
      visit "/"
      it_will_fetch_an_oauth_request_token
      click_link("connect through Trello")
      expect(page.current_path).to eq("/authorize_url")
    end
  end

  context "I return from a successful Trello authentication" do

    scenario "user is already known"

    scenario "user is unknown" do
      it_will_fetch_an_oauth_access_token
      it_will_fetch_trello_username
      visit "/trello/connection/callback?oauth_token=012345&oauth_verifier=67890"
    end
  end

  # Implementation

  def it_will_fetch_an_oauth_request_token
    request_token = double("request token", token: "token", secret: "secret", authorize_url: "authorize_url")
    oauth_consumer = double("OAuth::Consumer", get_request_token: request_token)
    expect(OAuth::Consumer).to receive(:new).and_return(oauth_consumer)
  end

  def it_will_fetch_an_oauth_access_token
    access_token = double("access token", token: "token", secret: "secret")
    request_token = double("request token", get_access_token: access_token)
    expect(OAuth::RequestToken).to receive(:new).and_return(request_token)
  end

  def it_will_fetch_trello_username
    trello_client = double("Letto::Integrations::Trello::Client", username: "username")
    expect(Letto::Integrations::Trello::Client).to receive(:new).and_return(trello_client)
  end
end
