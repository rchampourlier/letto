# frozen_string_literal: true
require "spec_helper"
require "workflows/node"

module Letto
  module Workflows
    class SpecNode < Node
      def check!
      end
    end
  end
end

describe Letto::Workflows::Node do

  def build
    described_class.build(data: data)
  end

  let(:type) { "spec" }
  let(:value) { "value" }
  let(:data) do
    {
      "type" => type,
      "value" => value
    }
  end

  describe ".build(data:)" do

    it "builds a node of the correct type" do
      expect(build).to be_a Letto::Workflows::SpecNode
    end

    context "no type" do
      let(:type) { nil }

      it "raises an error" do
        expect { build }.to raise_error(
          Letto::Workflows::Error,
          format(Letto::Workflows::Node::ERR_MSG_DATA_INVALID_MISSING_TYPE, data)
        )
      end
    end

    context "unknown type" do
      let(:type) { "unknown" }

      it "raises an error" do
        expect { build }.to raise_error(
          Letto::Workflows::Error,
          format(Letto::Workflows::Node::ERR_MSG_TYPE_UNKNOWN, "unknown")
        )
      end
    end
  end

  describe "#initialize(data:)" do
    subject { Letto::Workflows::SpecNode.new(data: data) }

    context "invalid data" do

      context "not an Hash" do
        let(:data) { "string" }

        it "raises an error" do
          expect { subject }.to raise_error(
            Letto::Workflows::Error,
            format(Letto::Workflows::Node::ERR_MSG_DATA_INVALID_MUST_BE_HASH, data)
          )
        end
      end

      context "missing `type`" do
        let(:type) { nil }

        it "raises an error" do
          expect { subject }.to raise_error(
            Letto::Workflows::Error,
            format(Letto::Workflows::Node::ERR_MSG_DATA_INVALID_MISSING_TYPE, data)
          )
        end
      end
    end

    context "type does not match" do
      let(:type) { "not_spec" }

      it "raises an error" do
        expect { Letto::Workflows::SpecNode.new(data: data) }.to raise_error(
          Letto::Workflows::Error,
          format(Letto::Workflows::Node::ERR_MSG_TYPE_DOES_NOT_MATCH, type, Letto::Workflows::SpecNode)
        )
      end
    end
  end
end
