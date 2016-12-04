# frozen_string_literal: true
require "spec_helper"

feature "As an user I visit the homepage so that I can access the service" do

  scenario "displays an invitation to connect" do
    visit("/")
    expect(page).to have_content("You must connect:")
  end
end
