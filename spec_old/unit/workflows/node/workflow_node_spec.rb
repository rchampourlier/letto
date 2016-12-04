# frozen_string_literal: true
require "spec_helper"
require "workflows/node/workflow_node"
require "workflows/node/operation_node"

describe Letto::Workflows::WorkflowNode do
  let(:node) { described_class.new(data: data) }
  let(:context) { {} }
  let(:data) do
    {
      "type" => "workflow",
      "condition" => condition,
      "action" => action
    }
  end

  describe "initialize(data:)" do
    context "no issue" do
      it "passes" do
        expect { node }.not_to raise_error
      end
    end

    context "missing condition" do
      let(:condition) { nil }

      it "raises an error" do
        expect { node }.to raise_error(
          Letto::Workflows::Error,
          format(Letto::Workflows::WorkflowNode::ERR_MSG_MISSING_CONDITION, data)
        )
      end
    end

    context "missing action" do
      let(:action) { nil }

      it "raises an error" do
        expect { node }.to raise_error(
          Letto::Workflows::Error,
          format(Letto::Workflows::WorkflowNode::ERR_MSG_MISSING_ACTION, data)
        )
      end
    end

    context "action is not an operation" do
      let(:action) { expression(value: "abc") }

      it "raises an error" do
        expect { node }.
          to raise_error(
            Letto::Workflows::Error,
            format(
              Letto::Workflows::WorkflowNode::ERR_MSG_ACTION_NOT_OPERATION,
              data
            )
          )
      end
    end
  end

  describe "#condition_true?(context:)" do
    before do
      allow(Letto::Workflows::OperationNode).
        to receive(:new).
        and_return(condition_node)
    end
    let(:condition_node) { double("OperationNode", evaluate: evaluate) }
    let(:evaluate) { true }

    context "condition evaluates to true" do
      it "returns true" do
        expect(node.condition_true?(context: context)).to eq(true)
      end
    end

    context "condition evaluates to false" do
      let(:evaluate) { false }

      it "returns false" do
        expect(node.condition_true?(context: context)).to eq(false)
      end
    end

    context "condition evaluates to a non-boolean value" do
      let(:evaluate) { "string" }

      it "raises an error" do
        expect { node.condition_true?(context: context) }.
          to raise_error(
            Letto::Workflows::Error,
            format(
              Letto::Workflows::WorkflowNode::ERR_MSG_CONDITION_RETURN_VALUE_NOT_BOOLEAN,
              data
            )
          )
      end
    end
  end

  describe "#evaluate(context:)" do
    before do
      allow(Letto::Workflows::OperationNode).
        to receive(:new).
        and_return(action_node)
    end
    let(:action_node) { double("OperationNode", evaluate: "evaluation-result") }

    it "returns the evaluation of the \"action\" node" do
      expect(node.evaluate(context: context)).to eq("evaluation-result")
    end
  end
end
