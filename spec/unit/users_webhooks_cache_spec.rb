# frozen_string_literal: true

require "spec_helper"
require "users_webhooks_cache"

describe Letto::UsersWebhooksCache do
  let(:webhook_url_root) { "https://letto.test/callbacks" }

  let(:users) do
    [
      { uuid: "user001", trello_access_token: "at001", trello_access_token_secret: "ats001" },
      { uuid: "user002", trello_access_token: "at002", trello_access_token_secret: "ats002" }
    ]
  end

  let(:trello_client_0) { double("trello_client_0", webhooks: trello_clients_webhooks_call_responses[0]) }
  let(:trello_client_1) { double("trello_client_1", webhooks: trello_clients_webhooks_call_responses[1]) }
  let(:trello_clients) { [trello_client_0, trello_client_1] }

  let(:trello_clients_webhooks_call_responses) do
    [
      [
        { callback_url: "https://letto.test/callbacks/callback001" },
        { callback_url: "https://letto.test/callbacks/callback003" }
      ].map { |attr| double(attributes: attr) },
      [
        { callback_url: "https://letto.test/callbacks/callback002" }
      ].map { |attr| double(attributes: attr) }
    ]
  end

  let(:expected_value) do
    {
      "callback001" => {
        uuid: "user001",
        access_token: "at001",
        access_token_secret: "ats001"
      },
      "callback002" => {
        uuid: "user002",
        access_token: "at002",
        access_token_secret: "ats002"
      },
      "callback003" => {
        uuid: "user001",
        access_token: "at001",
        access_token_secret: "ats001"
      }
    }
  end

  subject { described_class.new }

  before do
    allow(Letto::Data::UserRepository).to receive(:all).and_return(users)
    allow(Letto::TrelloClient).to receive(:new).with(
      users[0][:trello_access_token], users[0][:trello_access_token_secret]
    ).and_return(trello_clients[0])
    allow(Letto::TrelloClient).to receive(:new).with(
      users[1][:trello_access_token], users[1][:trello_access_token_secret]
    ).and_return(trello_clients[1])
  end

  describe "#fetch(webhook_url_root)" do

    it "builds an hash mapping callback ids to the corresponding user information" do
      subject.fetch(webhook_url_root: webhook_url_root)
      expect(subject.value).to eq(expected_value)
    end

    context "invalid OAuth tokens for a given user" do
      let(:trello_client_0) do
        client = double("trello_client_1")
        allow(client).to receive(:webhooks).and_raise(Trello::Error)
        client
      end

      it "clears the tokens for the user from the DB" do
        expect(Letto::Data::UserRepository).to receive(:update_by_uuid).with(
          users[0][:uuid],
          trello_access_token: nil,
          trello_access_token_secret: nil
        )
        subject.fetch(webhook_url_root: webhook_url_root)
      end

      it "still feeds the hash for other users" do
        allow(Letto::Data::UserRepository).to receive(:update_by_uuid)
        subject.fetch(webhook_url_root: webhook_url_root)
        expect(subject.value).to eq(expected_value.slice("callback002"))
      end
    end
  end

  describe "#remove_callback_from_cache(callback_id)" do
    before { subject.fetch(webhook_url_root: webhook_url_root) }

    it "removes the callback from the cache" do
      subject.remove_callback_from_cache("callback001")
      expect(subject.value).to eq(expected_value.slice("callback002", "callback003"))
    end
  end

  describe "#user_uuid_from_callback(callback_id)" do
    before { subject.fetch(webhook_url_root: webhook_url_root) }

    it "returns the user's uuid matching the specified callback id" do
      expect(subject.user_uuid_from_callback("callback001")).to eq("user001")
    end
  end

  describe "#trello_client_from_callback(callback_id)" do
    before { subject.fetch(webhook_url_root: webhook_url_root) }

    it "returns a Trello client for the user matching the specified callback" do
      expect(subject.trello_client_from_callback("callback001")).to eq(trello_clients[0])
    end
  end
end
