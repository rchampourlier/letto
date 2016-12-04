# frozen_string_literal: true
require "spec_helper"
require "workflows/function/extract"

describe Letto::Workflows::Function::Extract do

  let(:arguments) do
    {
      "path" => "name",
      "data" => {
        "id" => "56e27c9f152c3f92fd605034",
        "idBoard" => "56e27c9f92c67d0a687781bb",
        "name" => "active contact",
        "color" => "green",
        "uses" => 13
      }
    }
  end
  let(:context) { {} }

  subject { described_class.new.run(arguments: arguments, context: context) }

  it "returns the extracted value" do
    expect(subject).to eq("active contact")
  end
end
