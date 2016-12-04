# frozen_string_literal: true
require "spec_helper"
require "workflows/function/log"

describe Letto::Workflows::Function::Log do

  let(:arguments) do
    { "message" => "message" }
  end
  let(:context) { {} }

  it "logs the specified argument using `Letto::LOGGER`" do
    expect(Letto::LOGGER).to receive(:info).with("message")
    described_class.new.run(arguments: arguments, context: context)
  end
end
