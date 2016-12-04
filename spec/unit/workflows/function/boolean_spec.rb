# frozen_string_literal: true
require "spec_helper"
require "workflows/function/boolean"

describe Letto::Workflows::Function::Boolean do
  let(:arguments) do
    {
      "values" => values,
      "operation" => operation
    }
  end
  let(:values) { [ true, true ] }
  let(:operation) { "and" }
  let(:context) { {} }

  subject do
    described_class.new.run(arguments: arguments, context: context)
  end

  context "invalid values" do

    context "array containing non-boolean values" do
      let(:values) { ["string", true] }

      it "raises an error" do
        expect { subject }.to raise_error(
          Letto::Workflows::Function::Error,
          format(Letto::Workflows::Function::Boolean::ERR_MSG_VALUES_INVALID_MUST_BE_BOOLEANS, values)
        )
      end
    end

    context "not an array" do
      let(:values) { "string" }

      it "raises an error" do
        expect { subject }.to raise_error(
          Letto::Workflows::Function::Error,
          format(Letto::Workflows::Function::Boolean::ERR_MSG_VALUES_INVALID_MUST_BE_ARRAY, values)
        )
      end
    end
  end

  context "invalid operation" do
    let(:operation) { "unknown" }

    it "raises an error" do
      expect { subject }.to raise_error(
        Letto::Workflows::Function::Error,
        format(Letto::Workflows::Function::Boolean::ERR_MSG_OPERATION_INVALID_UNKNOWN, operation)
      )
    end
  end
end
