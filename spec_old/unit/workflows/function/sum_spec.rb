# frozen_string_literal: true
require "spec_helper"
require "workflows/function/sum"

describe Letto::Workflows::Function::Sum do

  let(:arguments) do
    {
      "values" => [1, 2, 3]
    }
  end
  let(:context) { {} }

  subject { described_class.new.run(arguments: arguments, context: context) }

  it "returns the result of the addition" do
    expect(subject).to eq(6)
  end
end
