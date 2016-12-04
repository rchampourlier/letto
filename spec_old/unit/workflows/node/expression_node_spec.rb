# frozen_string_literal: true
require "spec_helper"
require "active_support/inflector"
require "workflows/node/expression_node"

def expect_node_error(error_msg_key, node_data)
  error_msg_const = described_class.const_get("ERR_MSG_#{error_msg_key.to_s.upcase}")
  expect { subject }.to raise_error(
    Letto::Workflows::Error,
    format(error_msg_const, node_data)
  )
end

describe Letto::Workflows::ExpressionNode do
  let(:root) { Letto::Workflows::Evaluation.new(user_uuid: user_uuid) }
  let(:user_uuid) { "user_uuid" }

  let(:node_data) do
    {
      "type" => "expression",
      "value" => value,
      "value_type" => value_type
    }
  end
  let(:node) { described_class.new(data: node_data) }
  let(:value_type) { "value" }
  let(:value) { "value" }

  let(:context) do
    {
      "action" => {
        "card" => {
          "id" => "card_id"
        }
      }
    }
  end

  describe "#evaluate(context:)" do
    subject { node.evaluate(context: context) }

    context "values" do
      let(:value_type) { "value" }

      context "static" do
        let(:value) { 2 }

        it "returns the static value" do
          expect(subject).to eq(2)
        end
      end

      context "dynamic" do
        let(:value) { "{{ action.card.id }}" }

        it "returns the expression with context's data" do
          expect(subject).to eq("card_id")
        end
      end
    end

    context "nested expression" do

      context "array" do
        let(:value_type) { "array" }
        let(:value) do
          [
            {
              "type" => "expression",
              "value" => 2,
              "value_type" => "value"
            },
            {
              "type" => "expression",
              "value" => "{{ action.card.id }}",
              "value_type" => "value"
            }
          ]
        end

        it "returns the array with evaluated dynamic expressions" do
          expect(subject).to eq([2, "card_id"])
        end
      end

      context "hash" do
        let(:value_type) { "hash" }
        let(:value) do
          {
            "static" => {
              "type" => "expression",
              "value" => 2,
              "value_type" => "value"
            },
            "dynamic" => {
              "type" => "expression",
              "value" => "{{ action.card.id }}",
              "value_type" => "value"
            }
          }
        end

        it "returns the hash with evaluated expressions" do
          expect(subject).to eq(
            "static" => 2,
            "dynamic" => "card_id"
          )
        end
      end
    end
  end

  describe "#check!" do
    subject { node.check! }

    context "no issue" do
      it "initialize successfully" do
        expect { subject }.not_to raise_error
      end
    end

    context "missing `value`" do
      let(:value) { nil }
      let(:value_type) { "value" }

      it "raises an error" do
        expect { subject }.to raise_error(
          Letto::Workflows::Error,
          format(Letto::Workflows::ExpressionNode::ERR_MSG_VALUE_MISSING, node_data)
        )
      end
    end

    context "missing `value_type`" do
      let(:value) { "value" }
      let(:value_type) { nil }

      it "raises an error" do
        expect_node_error(:value_type_missing, node_data)
      end
    end

    context "invalid `value_type`" do
      let(:value) { "value" }
      let(:value_type) { "unknown" }

      it "raises an error" do
        expect_node_error(:value_type_invalid, node_data)
      end
    end

    context "nested expression" do

      context "array" do
        let(:value_type) { "array" }

        context "non-array `value`" do
          let(:value) { "string" }

          it "raises an error" do
            expect_node_error(:value_invalid_not_array, node_data)
          end
        end

        context "one of the array's values is not a valid expression node" do
          let(:value) do
            [
              "wrong!",
              {
                "type" => "expression",
                "value" => "{{ action.card.id }}",
                "value_type" => "value"
              }
            ]
          end

          it "raises an error" do
            sub_error = Letto::Workflows::Error.new(
              format(Letto::Workflows::Node::ERR_MSG_DATA_INVALID_MUST_BE_HASH, "wrong!")
            )
            expect_node_error(:nested_expressions_invalid, sub_error)
          end
        end
      end

      context "hash" do
        let(:value_type) { "hash" }

        context "non-hash `value`" do
          let(:value) { "string" }

          it "raises an error" do
            expect_node_error(:value_invalid_not_hash, node_data)
          end
        end

        context "one of the hash' values is not a valid expression nodes" do
          let(:value) do
            {
              "static" => {
                "type" => "expression",
                "value" => 2,
                "value_type" => "value"
              },
              "dynamic" => "wrong!"
            }
          end

          it "raises an error" do
            sub_error = Letto::Workflows::Error.new(
              format(Letto::Workflows::Node::ERR_MSG_DATA_INVALID_MUST_BE_HASH, "wrong!")
            )
            expect_node_error(:nested_expressions_invalid, sub_error)
          end
        end
      end
    end
  end
end
