# frozen_string_literal: true

require "spec_helper"
require "trello_client"

describe Letto::TrelloClient do
  let(:consumer_key) { "CONSUMER_KEY" }
  let(:consumer_secret) { "CONSUMER_SECRET" }
  let(:access_token) { "access_token" }
  let(:access_token_secret) { "access_token_secret" }

  let(:client) { double("Trello::Client", oauth_token: access_token) }

  before do
    ENV["TRELLO_CONSUMER_KEY"] = consumer_key
    ENV["TRELLO_CONSUMER_SECRET"] = consumer_secret
  end

  subject { described_class.new(access_token, access_token_secret) }
  before { allow(subject).to receive(:client).and_return(client) }

  describe ".new(access_token, access_token_secret)" do
    it "returns a Trello::Client initialized with the correct credentials" do
      expect(Trello::Client).to receive(:new).with(
        consumer_key: consumer_key,
        consumer_secret: consumer_secret,
        oauth_token: access_token,
        oauth_token_secret: access_token_secret
      )
      described_class.new(access_token, access_token_secret)
    end
  end

  describe "#organizations" do
    it "fetches organizations for the \"me\" member" do
      expect(client).to receive(:find_many).with(Trello::Organization, "/members/me/organizations")
      subject.organizations
    end
  end

  describe "#boards" do
    it "fetches boards for the \"me\" member" do
      expect(client).to receive(:find_many).with(Trello::Board, "/members/me/boards")
      subject.boards
    end
  end

  describe "#webhooks" do
    it "fetches webhooks for the \"me\" member" do
      expect(client).to receive(:find_many).with(Trello::Webhook, "/tokens/#{access_token}/webhooks")
      subject.webhooks
    end
  end

  describe "#username" do
    it "returns the member's username" do
      expect(client).to receive(:find).with(:members, "me").and_return(double("member", username: "username"))
      expect(subject.username).to eq("username")
    end
  end

  describe "#delete_webhook(webhook_id)" do
    it "performs the delete call through Trello::Client" do
      expect(client).to receive(:delete).with("/webhooks/webhook_id")
      subject.delete_webhook("webhook_id")
    end
  end

  describe "#delete_token(token_id)" do
    it "performs the delete call through Trello::Client" do
      expect(client).to receive(:delete).with("/tokens/token_id")
      subject.delete_token("token_id")
    end
  end

  describe "#api_call(verb, target, payload)" do
    it "performs the api call through Trello::Client" do
      expect(client).to receive(:verb).with("target", "payload")
      subject.api_call("verb", "target", "payload")
    end
  end

  describe "create_board_webhook(board_id, callback_url, description)" do
    it "performs the create call through Trello::Client" do
      allow(SecureRandom).to receive(:uuid).and_return("webhook_id")
      expect(client).to receive(:create).with(
        :webhook,
        "description" => "description",
        "idModel" => "board_id",
        "callbackURL" => "url/webhook_id"
      )
      subject.create_board_webhook("board_id", "url", "description")
    end
  end
end
