# frozen_string_literal: true
require "spec_helper"
require "runner"
require "values/webhook"
require "trello_client"

describe Letto::Runner do

  def build_webhook(id: "id", body: {})
    Letto::Values::Webhook.new(id, {}, body.to_json)
  end

  let(:config) { {} }
  subject { described_class.new(config) }

  describe "execute_action" do
    context "evaluate_value" do
      let(:action) do
        {
          "type" => "value",
          "value" => 2
        }
      end

      it "returns 2" do
        webhook = build_webhook()
        execute_action = subject.execute_action(action, webhook)
        expect(execute_action).to eq(2)
      end
    end

    context "evaluate_expression" do
      let(:action) do
        {
          "type" => "expression",
          "value" => "action.card.id"
        }
      end

      it "returns the card ID" do
        webhook = build_webhook(
          body: {
            "action" => {
              "card" => {
                "id" => "card_id"
              }
            }
          }
        )
        execute_action = subject.execute_action(action, webhook)
        expect(execute_action).to eq("card_id")
      end
    end

    context "apply_function_add" do
      let(:action) do
        {
          "type" => "operation",
          "function" => "add",
          "arguments" => [
            {
              "type" => "value",
              "value" => 1
            },
            {
              "type" => "value",
              "value" => 2
            },
            {
              "type" => "value",
              "value" => 3
            }
          ]
        }
      end

      it "returns 6" do
        webhook = build_webhook()
        execute_action = subject.execute_action(action, webhook)
        expect(execute_action).to eq(6)
      end
    end

    context "apply_function_min" do
      let(:action) do
        {
          "type" => "operation",
          "function" => "min",
          "arguments" => [
            {
              "type" => "value",
              "value" => 2
            },
            {
              "type" => "value",
              "value" => 1
            },
            {
              "type" => "value",
              "value" => 3
            }
          ]
        }
      end

      it "returns 1" do
        webhook = build_webhook()
        execute_action = subject.execute_action(action, webhook)
        expect(execute_action).to eq(1)
      end
    end

    context "apply_function_extract" do
      let(:action) do
        {
          "type" => "operation",
          "function" => "extract",
          "arguments" => [
            {
              "type" => "value",
              "value" => "name"
            },
            {
              "type" => "value",
              "value" => [
                {
                  "id" => "56e27c9f152c3f92fd605034",
                  "idBoard" => "56e27c9f92c67d0a687781bb",
                  "name" => "active contact",
                  "color" => "green",
                  "uses" => 13
                }
              ]
            }
          ]
        }
      end

      it "returns ['active contact']" do
        webhook = build_webhook()
        execute_action = subject.execute_action(action, webhook)
        expect(execute_action).to eq(["active contact"])
      end
    end

    context "apply_function_map" do
      let(:action) do
        {
          "type" => "operation",
          "function" => "map",
          "arguments" => [
            {
              "type"=> "value",
              "value" => [ "active contact" ]
            },
            {
              "type" => "value",
              "value" => {
                "active contact" => 7,
                "passive contact" => 30
              }
            }
          ]
        }
      end

      it "returns [7]" do
        webhook = build_webhook()
        execute_action = subject.execute_action(action, webhook)
        expect(execute_action).to eq([7])
      end
    end

    context "apply_function_api_call" do
      let(:action) do
        {
          "type" => "operation",
          "function" => "api_call",
          "arguments" => [
            {
              "type" => "value",
              "value" => "POST"
            },
            {
              "type" => "target",
              "value" => "/cards/{{ action.card.id }}",
            },
            {
              "type" => "payload",
              "value" => {
                "due" => {
                  "type" => "value",
                  "value" => "due"
                }
              }
            }
          ]
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
