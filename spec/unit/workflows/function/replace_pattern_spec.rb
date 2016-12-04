# frozen_string_literal: true
require "spec_helper"
require "workflows/function/replace_pattern"

describe Letto::Workflows::Function::ReplacePattern do

  let(:arguments) do
    {
      "source" => "the source string",
      "pattern_type" => pattern_type,
      "pattern" => pattern,
      "replacement" => "replacement"
    }
  end
  let(:context) { {} }
  let(:pattern_type) { "string" }
  let(:pattern) { "source" }

  subject { described_class.new.run(arguments: arguments, context: context) }

  context "pattern is a string" do
    it "replaces the matched string with the replacement" do
      expect(subject).to eq("the replacement string")
    end
  end

  context "pattern is a regexp" do
    let(:pattern) { "s(.+)e" }
    let(:pattern_type) { "regexp" }

    it "replaces the matched string with the replacement" do
      expect(subject).to eq("the replacement string")
    end
  end

  context "unknown pattern type" do
    let(:pattern_type) { "unknown" }

    it "raises an error" do
      expect { subject }.to raise_error(
        Letto::Workflows::Function::Error,
        format(Letto::Workflows::Function::ReplacePattern::ERR_MSG_PATTERN_TYPE_UNKNOWN, "unknown")
      )
    end
  end
end
