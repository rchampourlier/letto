# frozen_string_literal: true
require "event_train"
require "workflows/node"

module Letto

  # Top-level module to handle workflows.
  #
  # `Workflows.start` setup the subscription to the event bus. It will
  # terminate, since it is expected to be run within the webserver's
  # process which itself already remains active.
  module Workflows
    extend CoreModule

    Error = Class.new(StandardError)

    # Starting the `Workflows` module which will listen for events
    # and execute workflows appropriately.
    def self.start(config:)
      EventTrain.subscribe do |event_name:, event_data:|
        LOGGER.info "Received event `#{event_name}` (data: #{event_data})"
        user_uuid = event_data["user_uuid"]
        workflows = Selection.new(user_uuid: user_uuid).perform
        run = Run.new(user_uuid: user_uuid)
        workflows.each { |workflow| run.perform(workflow: workflow, context: event_data) }
      end
    end

    # Build a new instance of a workflow. A workflow is a tree of node so the
    # instance of a workflow is a `Node` of type `workflow`.
    def self.build(data:)
      Node.build(data: data)
    end
  end
end
