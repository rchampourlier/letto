# # frozen_string_literal: true
# require "spec_helper"
# require "workflows/evaluation"
#
# module Letto
#   module Workflows
#     class Evaluation
#       class SomeType
#         def initialize(user_uuid:)
#         end
#
#         def run(node:, _context:)
#           "result"
#         end
#       end
#     end
#   end
# end
#
# describe Letto::Workflows::Evaluation do
#   let(:node) do
#     {
#       "type" => "some_type"
#     }
#   end
#   let(:context) { {} }
#   let(:user_uuid) { "user_uuid" }
#
#   subject do
#     described_class.new(user_uuid: user_uuid).run(node: node, context: context)
#   end
#
#   describe ".run(node:, context:)" do
#     it "performs the evaluation using the class corresponding to the node's type" do
#       expect(subject).to eq("result")
#     end
#   end
#
#   describe "execute_action" do
#
#
#     context "apply_function_map" do
#       let(:action) do
#         {
#           "type" => "operation",
#           "function" => "map",
#           "arguments" => [
#             {
#               "type" => "expression",
#               "value" => ["active contact"]
#             },
#             {
#               "type" => "expression",
#               "value" => {
#                 "active contact" => 7,
#                 "passive contact" => 30
#               }
#             }
#           ]
#         }
#       end
#
#       it "returns [7]" do
#         execute_action = subject.execute_action(action, context)
#         expect(execute_action).to eq([7])
#       end
#     end
#
#     describe "apply_function_convert" do
#       context "conversion from String to DateTime" do
#         let(:action) do
#           {
#             "type" => "operation",
#             "function" => "convert",
#             "arguments" => [
#               {
#                 "type" => "expression",
#                 "value" => "DateTime"
#               },
#               {
#                 "type" => "expression",
#                 "value" => "2016-10-03T20:09:32.301Z"
#               }
#             ]
#           }
#         end
#
#         it "returns an object DateTime from the parsed string" do
#           execute_action = subject.execute_action(action, context)
#           expect(execute_action).to eq(DateTime.parse("2016-10-03T20:09:32.301Z"))
#         end
#       end
#
#       context "conversion from Integer to String" do
#         let(:action) do
#           {
#             "type" => "operation",
#             "function" => "convert",
#             "arguments" => [
#               {
#                 "type" => "expression",
#                 "value" => "String"
#               },
#               {
#                 "type" => "expression",
#                 "value" => 2016
#               }
#             ]
#           }
#         end
#
#         it "returns a string \"2016\"" do
#           execute_action = subject.execute_action(action, context)
#           expect(execute_action).to eq("2016")
#         end
#       end
#     end
#   end
# end
