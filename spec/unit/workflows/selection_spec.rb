# # frozen_string_literal: true
# require "spec_helper"
# require "workflows/selection"
#
# describe Letto::Workflows::Selection do
#
#   describe "matching_workflows" do
#     let(:config) do
#       {
#         "workflows" => [
#           {
#             "name" => "someWorkflow",
#             "context_id" => "id",
#             "conditions" => []
#           }
#         ]
#       }
#     end
#
#     describe "string_comparison condition" do
#       let(:config) do
#         {
#           "workflows" => [
#             {
#               "name" => "someWorkflow",
#               "context_id" => "id",
#               "conditions" => [
#                 {
#                   "type" => "string_comparison",
#                   "path" => "action.type",
#                   "value" => "addLabelToCard"
#                 }
#               ]
#             }
#           ]
#         }
#       end
#
#       context "matching" do
#         let(:context) do
#           {
#             body: {
#               "action" => { "type" => "addLabelToCard" }
#             }
#           }
#         end
#
#         it "returns 1 workflow" do
#           matching_workflows = subject.matching_workflows(context)
#           expect(matching_workflows.count).to eq(1)
#         end
#       end
#
#       context "non-matching" do
#         let(:context) do
#           {
#             body: {
#               "action" => { "type" => "other" }
#             }
#           }
#         end
#
#         it "returns 0 workflows" do
#           matching_workflows = subject.matching_workflows(context)
#           expect(matching_workflows.count).to eq(0)
#         end
#       end
#     end
#
#     describe "string_comparison condition" do
#       let(:config) do
#         {
#           "workflows" => [
#             {
#               "name" => "someWorkflow",
#               "context_id" => "id",
#               "conditions" => [
#                 {
#                   "type" => "string_comparison",
#                   "path" => "action.type",
#                   "value" => "addLabelToCard"
#                 }
#               ]
#             }
#           ]
#         }
#       end
#
#       context "matching" do
#         it "returns 1 workflow" do
#           context = build_context(
#             body: {
#               "action" => { "type" => "addLabelToCard" }
#             }
#           )
#           matching_workflows = subject.matching_workflows(context)
#           expect(matching_workflows.count).to eq(1)
#         end
#       end
#
#       context "non-matching" do
#         it "returns 0 workflows" do
#           context = build_context(
#             body: {
#               "action" => { "type" => "other" }
#             }
#           )
#           matching_workflows = subject.matching_workflows(context)
#           expect(matching_workflows.count).to eq(0)
#         end
#       end
#     end
#
#     describe "string_comparison condition" do
#       let(:config) do
#         {
#           "workflows" => [
#             {
#               "name" => "someWorkflow",
#               "context_id" => "id",
#               "conditions" => [
#                 {
#                   "type" => "string_comparison",
#                   "path" => "action.type",
#                   "value" => "addLabelToCard"
#                 }
#               ]
#             }
#           ]
#         }
#       end
#
#       context "matching" do
#         it "returns 1 workflow" do
#           context = build_context(
#             body: {
#               "action" => { "type" => "addLabelToCard" }
#             }
#           )
#           matching_workflows = subject.matching_workflows(context)
#           expect(matching_workflows.count).to eq(1)
#         end
#       end
#
#       context "non-matching" do
#         it "returns 0 workflows" do
#           context = build_context(
#             body: {
#               "action" => { "type" => "other" }
#             }
#           )
#           matching_workflows = subject.matching_workflows(context)
#           expect(matching_workflows.count).to eq(0)
#         end
#       end
#     end
#
#     describe "regex_comparison condition" do
#       let(:config) do
#         {
#           "workflows" => [
#             {
#               "name" => "someWorkflow",
#               "context_id" => "id",
#               "conditions" => [
#                 {
#                   "type" => "regex_comparison",
#                   "path" => "action.type",
#                   "value" => "add.*"
#                 }
#               ]
#             }
#           ]
#         }
#       end
#
#       context "matching" do
#         it "returns 1 workflow" do
#           context = build_context(
#             body: {
#               "action" => { "type" => "addLabelToCard" }
#             }
#           )
#           matching_workflows = subject.matching_workflows(context)
#           expect(matching_workflows.count).to eq(1)
#         end
#       end
#
#       context "non-matching" do
#         it "returns 0 workflows" do
#           context = build_context(
#             body: {
#               "action" => { "type" => "other" }
#             }
#           )
#           matching_workflows = subject.matching_workflows(context)
#           expect(matching_workflows.count).to eq(0)
#         end
#       end
#     end
#
#     describe "multiple matchings workflows" do
#       let(:config) do
#         {
#           "workflows" => [
#             {
#               "name" => "someWorkflow",
#               "context_id" => "id",
#               "conditions" => [
#                 {
#                   "type" => "string_comparison",
#                   "path" => "action.type",
#                   "value" => %w(addLabelToCard cardCreated)
#                 }
#               ]
#             }
#           ]
#         }
#       end
#
#       context "matching" do
#         it "returns 1 workflow" do
#           context = build_context(
#             body: {
#               "action" => { "type" => "addLabelToCard" }
#             }
#           )
#           matching_workflows = subject.matching_workflows(context)
#           expect(matching_workflows.count).to eq(1)
#         end
#       end
#
#       context "non-matching" do
#         it "returns 0 workflows" do
#           context = build_context(
#             body: {
#               "action" => { "type" => "other" }
#             }
#           )
#           matching_workflows = subject.matching_workflows(context)
#           expect(matching_workflows.count).to eq(0)
#         end
#       end
#     end
#   end
# end
