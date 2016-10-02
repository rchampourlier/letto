# frozen_string_literal: true
require "spec_helper"
require "runner"
require "values/webhook"

describe Letto::Runner do

  def build_webhook(id: "id", body: {})
    Letto::Values::Webhook.new(id, {}, body.to_json)
  end

  let(:config) { {} }
  subject { described_class.new(config) }

  describe "execute_action" do
    let(:action) do
      {
        "type" => "operation",
        "function" => "api_call",
        "arguments" => {
          "verb" => "POST",
          "target" => "/cards/{{ action.card.id }}",
          "payload" => {
            "due" => {
              "type" => "value",
              "value" => "due"
            }
          }
        }
      }
    end

    it "runs the expected API call" do
      webhook = build_webhook(
        body: {
          "action" => {
            "card" => {
              "id" => "card_id"
            }
          }
        }
      )
      expect(Letto::TrelloClient).to receive(:api_call).with(
        "POST",
        "/cards/card_id",
        "due" => "due"
      )
      subject.execute_action(action, webhook)
    end
  end

  describe "matching_workflows" do
    let(:config) do
      {
        "workflows" => [
          {
            "name" => "someWorkflow",
            "webhook_id" => "id",
            "conditions" => []
          }
        ]
      }
    end

    describe "webhook_id comparison" do
      context "matching" do
        it "returns 1 workflow" do
          matching_workflows = subject.matching_workflows(build_webhook)
          expect(matching_workflows.count).to eq(1)
        end
      end

      context "non-matching" do
        it "returns an empty array" do
          matching_workflows = subject.matching_workflows(build_webhook(id: "unknown"))
          expect(matching_workflows).to eq([])
        end
      end
    end

    describe "string_comparison condition" do
      let(:config) do
        {
          "workflows" => [
            {
              "name" => "someWorkflow",
              "webhook_id" => "id",
              "conditions" => [
                {
                  "type" => "string_comparison",
                  "path" => "action.type",
                  "value" => "addLabelToCard"
                }
              ]
            }
          ]
        }
      end

      context "matching" do
        it "returns 1 workflow" do
          webhook = build_webhook(
            body: {
              "action" => { "type" => "addLabelToCard" }
            }
          )
          matching_workflows = subject.matching_workflows(webhook)
          expect(matching_workflows.count).to eq(1)
        end
      end

      context "non-matching" do
        it "returns 0 workflows" do
          webhook = build_webhook(
            body: {
              "action" => { "type" => "other" }
            }
          )
          matching_workflows = subject.matching_workflows(webhook)
          expect(matching_workflows.count).to eq(0)
        end
      end
    end
  end
end
