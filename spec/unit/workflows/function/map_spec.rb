# frozen_string_literal: true
require "spec_helper"
require "workflows/function/map"

describe Letto::Workflows::Function::Map do

  let(:arguments) do
    {
      "mapping_table" => {
        "a" => "A",
        "b" => "B",
        "c" => "C",
        "d" => "D"
      },
      "values" => %w(a b d)
    }
  end
  let(:context) { {} }

  subject do
    described_class.new.run(
      arguments: arguments,
      context: context
    )
  end

  it "returns the mapped values" do
    expect(subject).to eq(%w(A B D))
  end
end
