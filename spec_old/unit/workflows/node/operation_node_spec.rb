# frozen_string_literal: true
require "spec_helper"
require "workflows/function"
require "workflows/node/operation_node"

describe Letto::Workflows::OperationNode do
  let(:node) { described_class.new(data: data) }
  let(:context) { {} }
  let(:function) { "sum" }
  let(:arguments) { { "values" => values_node } }
  let(:values_node) do
    {
      "type" => "expression",
      "value_type" => "array",
      "value" => [
        { "type" => "expression", "value_type" => "value", "value" => 1 },
        { "type" => "expression", "value_type" => "value", "value" => 2 }
      ]
    }
  end
  let(:data) do
    {
      "type" => "operation",
      "function" => function,
      "arguments" => arguments
    }
  end

  describe "#check!" do
    subject { node.check! }

    context "no issue" do
      it "initializes" do
        expect { subject }.not_to raise_error
      end
    end

    context "missing function" do
      let(:function) { nil }

      it "raises an error" do
        expect { node }.to raise_error(
          Letto::Workflows::Error,
          format(Letto::Workflows::OperationNode::ERR_MSG_FUNCTION_MISSING, data)
        )
      end
    end

    context "unknown function" do
      let(:function) { "unknown" }

      it "raises an error" do
        expect { node }.
          to raise_error(
            Letto::Workflows::Error,
            format(
              Letto::Workflows::OperationNode::ERR_MSG_FUNCTION_UNKNOWN,
              function,
              data
            )
          )
      end
    end

    context "missing arguments" do
      let(:arguments) { nil }

      it "raises an error" do
        expect { node }.to raise_error(
          Letto::Workflows::Error,
          format(Letto::Workflows::OperationNode::ERR_MSG_ARGUMENTS_MISSING, data)
        )
      end
    end
  end

  describe "#evaluate(context:)" do
    subject { node.evaluate(context: context) }

    it "returns the result of the function execution" do
      expect(subject).to eq(3)
    end

    context "function runtime error" do
      let(:function) { "log" }
      let(:message_node) do
        {
          "type" => "expression",
          "value_type" => "value",
          "value" => "message"
        }
      end
      let(:arguments) { { "not_message" => message_node } }

      it "raises an error" do
        function_error = "Function log expected arguments [\"message\"], got [\"not_message\"]"
        expect { subject }.to raise_error(
          Letto::Workflows::Error,
          format(Letto::Workflows::OperationNode::ERR_MSG_FUNCTION_RUNTIME_FAILURE, function_error)
        )
      end
    end
  end
end
