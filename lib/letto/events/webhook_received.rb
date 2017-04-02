# frozen_string_literal: true
require_relative '../workflows/selection'

# An incoming webhook was received.
class WebhookReceived < Letto::Event
  param :id, Types::Strict::String
  param :user_uuid, Types::Strict::String
  param :params, Types::Strict::Hash
  log_with Letto.dep(:logger)

  def perform_call
    puts "[NOT IMPLEMENTED] (called from #{caller.first})"
    # workflows = Workflows::Selection.new(user_uuid: user_uuid).perform
    # run = Run.new(user_uuid: user_uuid)
    # workflows.each { |workflow| run.perform(workflow: workflow, context: event_data) }
  end
end
