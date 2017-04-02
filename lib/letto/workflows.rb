# frozen_string_literal: true
require_relative './workflows/node'

# Top-level module to handle workflows.
#
# `Workflows.start` setup the subscription to the event bus. It will
# terminate, since it is expected to be run within the webserver's
# process which itself already remains active.
class Workflow < Hanami::Entity
  Error = Class.new(StandardError)

  # Build a new instance of a workflow. A workflow is a tree of node so the
  # instance of a workflow is a `Node` of type `workflow`.
  def self.build(data:)
    Node.build(data: data)
  end

  # Return workflows for the specified `user_uuid` and `uuid`.
  def self.where(user_uuid:, uuid:)

  end
end
