# frozen_string_literal: true
require "spec_helper"
require "runner"
require "values/webhook"
require "trello_client"
require "users_webhooks_cache"
require "workflows_checker"

describe Letto::Runner do

  def build_webhook(id: "id", body: {})
    Letto::Values::Webhook.new(id, {}, body.to_json)
  end

  let(:config) { {} }
  let(:trello_client) { double("TrelloClient") }
  let(:users_webhooks_cache) { double("UsersWebhooksCache", trello_client_from_callback: trello_client) }

  subject { described_class.new(config, users_webhooks_cache) }

  before(:each) do
    allow(Letto::WorkflowsChecker).to receive(:check_workflows!).and_return(true)
  end

  describe "execute_action" do
    context "evaluate_expression" do
      context "static value" do
        let(:action) do
          {
            "type" => "expression",
            "value" => 2
          }
        end

        it "returns 2" do
          webhook = build_webhook
          execute_action = subject.execute_action(action, webhook)
          expect(execute_action).to eq(2)
        end
      end

      context "interpoled only" do
        let(:action) do
          {
            "type" => "expression",
            "value" => "{{ action.card.id }}"
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

      context "composed value" do
        let(:action) do
          {
            "type" => "expression",
            "value" => "card id: {{ action.card.id }}"
          }
        end

        it "returns the card ID prefixed by card id:" do
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
          expect(execute_action).to eq("card id: card_id")
        end
      end
    end

    context "apply_function_add" do
      let(:action) do
        {
          "type" => "operation",
          "function" => "add",
          "arguments" => [
            {
              "type" => "expression",
              "value" => 1
            },
            {
              "type" => "expression",
              "value" => 2
            },
            {
              "type" => "expression",
              "value" => 3
            }
          ]
        }
      end

      it "returns 6" do
        webhook = build_webhook
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
              "type" => "expression",
              "value" => 2
            },
            {
              "type" => "expression",
              "value" => 1
            },
            {
              "type" => "expression",
              "value" => 3
            }
          ]
        }
      end

      it "returns 1" do
        webhook = build_webhook
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
              "type" => "expression",
              "value" => "name"
            },
            {
              "type" => "expression",
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
        webhook = build_webhook
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
              "type" => "expression",
              "value" => ["active contact"]
            },
            {
              "type" => "expression",
              "value" => {
                "active contact" => 7,
                "passive contact" => 30
              }
            }
          ]
        }
      end

      it "returns [7]" do
        webhook = build_webhook
        execute_action = subject.execute_action(action, webhook)
        expect(execute_action).to eq([7])
      end
    end

    describe "apply_function_convert" do
      context "conversion from String to DateTime" do
        let(:action) do
          {
            "type" => "operation",
            "function" => "convert",
            "arguments" => [
              {
                "type" => "expression",
                "value" => "DateTime"
              },
              {
                "type" => "expression",
                "value" => "2016-10-03T20:09:32.301Z"
              }
            ]
          }
        end

        it "returns an object DateTime from the parsed string" do
          webhook = build_webhook
          execute_action = subject.execute_action(action, webhook)
          expect(execute_action).to eq(DateTime.parse("2016-10-03T20:09:32.301Z"))
        end
      end

      context "conversion from Integer to String" do
        let(:action) do
          {
            "type" => "operation",
            "function" => "convert",
            "arguments" => [
              {
                "type" => "expression",
                "value" => "String"
              },
              {
                "type" => "expression",
                "value" => 2016
              }
            ]
          }
        end

        it "returns a string \"2016\"" do
          webhook = build_webhook
          execute_action = subject.execute_action(action, webhook)
          expect(execute_action).to eq("2016")
        end
      end
    end

    context "apply_function_api_call" do
      let(:action) do
        {
          "type" => "operation",
          "function" => "api_call",
          "arguments" => [
            {
              "type" => "expression",
              "value" => "POST"
            },
            {
              "type" => "expression",
              "value" => "/cards/{{ action.card.id }}"
            },
            {
              "type" => "payload",
              "value" => {
                "due" => {
                  "type" => "expression",
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
        expect(trello_client).to receive(:api_call).with(
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

    describe "regex_comparison condition" do
      let(:config) do
        {
          "workflows" => [
            {
              "name" => "someWorkflow",
              "webhook_id" => "id",
              "conditions" => [
                {
                  "type" => "regex_comparison",
                  "path" => "action.type",
                  "value" => "add.*"
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

    describe "multiple matchings workflows" do
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
                  "value" => %w(addLabelToCard cardCreated)
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
