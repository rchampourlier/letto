# frozen_string_literal: true
require "spec_helper"
require "workflows/function/api_call"
require "integrations/trello"

describe Letto::Workflows::Function::ApiCall do
  let(:arguments) do
    {
      "verb" => "POST",
      "target" => "/cards/card_id",
      "payload" => {
        "due" => due_date
      }
    }
  end
  let(:context) { { "user_uuid" => user_uuid } }
  let(:user_uuid) { "some-user-uuid" }
  let(:due_date) { "2016-12-01 12:00:01" }

  subject do
    described_class.new.run(arguments: arguments, context: context)
  end

  it "performs the specified API call and returns its result" do
    expect(Letto::Integrations::Trello).
      to receive(:perform_api_call).
      with(
        user_uuid: user_uuid,
        verb: "POST",
        target: "/cards/card_id",
        payload: {
          "due" => due_date
        }
      )
    subject
  end
end
