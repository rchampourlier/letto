# frozen_string_literal: true
require "trello"

module SpecHelpers
  module Trello

    def given_the_trello_client_responds_with_webhooks(count: 1)
      trello_client = double("Trello::Client", oauth_token: "token")
      webhooks = Array.new(count) do |i|
        double(attributes: { id: i, description: "Webhook #{i}" })
      end
      expect(trello_client).
        to receive(:find_many).
        with(::Trello::Webhook, "/tokens/token/webhooks").
        and_return(webhooks)
      allow(::Trello::Client).to receive(:new).and_return(trello_client)
    end

    def given_the_trello_client_responds_with_boards(open:, closed:)
      trello_client = double("Trello::Client")
      organization1 = double(attributes: { id: 1, display_name: "Org 1" })
      boards = Array.new(open) do |i|
        double(attributes: { id: i, name: "Board #{i}", organization_id: 1, closed: false })
      end
      Array.new(closed) do |i|
        j = open + i
        boards << double(attributes: { id: j, name: "Board #{j}", organization_id: 1, closed: true })
      end
      organizations = [organization1]
      expect(trello_client).
        to receive(:find_many).
        with(::Trello::Organization, "/members/me/organizations").
        and_return(organizations)
      expect(trello_client).
        to receive(:find_many).
        with(::Trello::Board, "/members/me/boards").
        and_return(boards)
      allow(::Trello::Client).to receive(:new).and_return(trello_client)
    end

    def it_displays_the_list_of_boards(count: 1)
      expect(page).to have_selector(".boards_list--row", count: count)
    end

    def it_displays_the_list_of_webhooks(count: 1)
      expect(page).to have_selector(".webhooks_list--row", count: count)
    end
  end
end
