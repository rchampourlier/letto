# frozen_string_literal: true
require "spec_helper"
require "workflows/function/compare"

describe Letto::Workflows::Function::Compare do
  let(:arguments) do
    {
      "value1" => value1,
      "value2" => value2,
      "operation" => operation
    }
  end
  let(:value1) { 1 }
  let(:value2) { 2 }
  let(:operation) { "equality" }
  let(:context) { {} }

  subject do
    described_class.new.run(arguments: arguments, context: context)
  end

  context "operation is `equality`" do

    context "values are not equal" do
      it "returns false" do
        expect(subject).to equal(false)
      end
    end

    context "values are equal" do
      let(:value2) { value1 }
      it "returns true" do
        expect(subject).to equal(true)
      end
    end
  end
end
