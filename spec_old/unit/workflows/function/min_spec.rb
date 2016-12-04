# frozen_string_literal: true
require "spec_helper"
require "workflows/function/min"

describe Letto::Workflows::Function::Min do
  let(:arguments) do
    {
      "values" => values
    }
  end
  let(:values) { [1, 2, 3] }
  let(:context) { {} }

  subject { described_class.new.run(arguments: arguments, context: context) }

  it "returns the minimum of the specified arguments" do
    expect(subject).to eq(1)
  end
end
