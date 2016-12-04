# frozen_string_literal: true
require "spec_helper"
require "letto/incoming_webhooks"
require "letto/workflows"

def app
  Letto::IncomingWebhooks.start(config: {}, rack_builder: Rack::Builder.new)
end

# This spec tests the integration between several components over
# the following scenario:
#   - a webhook is received,
#   - a stored workflow matches the received webhook's data,
#   - the selected workflow is executed as expected.
describe "webhook triggering a workflow" do
  before(:all) do
    Letto::Workflows.start(config: {}, rack_builder: nil)
  end
  let(:user_uuid) { "user_uuid" }
  let(:matching_workflow) { workflow.to_json }
  let(:non_matching_workflow) do
    w = workflow
    w["condition"]["value"] = false
    w.to_json
  end

  before do
    [matching_workflow, non_matching_workflow].each do |workflow|
      Letto::Persistence::WorkflowRepository.create(
        user_uuid: user_uuid,
        data: workflow
      )
    end
  end

  it "executes the workflow" do
    message = "webhook-payload-value"
    logger = double("Logger", :level= => nil)
    allow(Logger).to receive(:new).and_return(logger)
    expect(logger).to receive(:info).with(message)
    body = { payload: { value: message } }.to_json
    post "/incoming_webhook/user_uuid/webhook_uuid", body
  end

  it "only executes the correct workflow" do
    expect(Letto::Workflows::Node).to receive(:build).once
    post "/incoming_webhook/user_uuid/webhook_uuid", body
  end
end
