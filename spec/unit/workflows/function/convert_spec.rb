# frozen_string_literal: true
require "spec_helper"
require "workflows/function/convert"

describe Letto::Workflows::Function::Convert do
  let(:arguments) do
    {
      "value" => value,
      "target_type" => "datetime"
    }
  end
  let(:value) { "2016-12-01 12:01:02" }
  let(:context) { {} }

  subject do
    described_class.new.run(arguments: arguments, context: context)
  end

  context "`target_type` is `datetime`" do
    it "converts to a  `DateTime` instance" do
      expect(subject).to eq(DateTime.parse(value))
    end
  end
end
