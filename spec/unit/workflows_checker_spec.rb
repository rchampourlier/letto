# frozen_string_literal: true
require "spec_helper"
require "rack/test"

require "workflows_checker"
describe "Letto::WorkflowsChecker" do
  let(:test_wf) do
    {
      "name" => "setDoneOnLabelDone",
      "conditions" => [
        {
          "type" => "string_comparison",
          "target" => "payload",
          "path" => "model.id",
          "value" => "57fa5578d7fb102d91d51c19"
        },
        {
          "type" => "string_comparison",
          "target" => "payload",
          "path" => "action.type",
          "value" => "addLabelToCard"
        }
      ],
      "action" => {
        "type" => "operation",
        "function" => "api_call",
        "arguments" => [
          {
            "type" => "value",
            "value" => "PUT"
          },
          {
            "type" => "target",
            "value" => "/cards/{{ action.data.card.id }}"
          },
          {
            "type" => "payload",
            "value" => {
              "name" => {
                "type" => "operation",
                "function" => "concat",
                "arguments" => [
                  {
                    "type" => "value",
                    "value" => "[Traité]"
                  },
                  {
                    "type" => "expression",
                    "value" => "action.data.card.name"
                  }
                ]
              }
            }
          }
        ]
      }
    }
  end

  it "raises an error unknown function" do
    expect {
      Letto::WorkflowsChecker.check_workflow(test_wf)
    }.to raise_error(Letto::WorkflowsChecker::Error, "Unknown function name: concat")

  end
end
