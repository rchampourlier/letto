# frozen_string_literal: true
require "active_support/inflector"
require "workflows"

module Letto
  module Workflows

    # Workflows are a tree of Nodes, that may be of different
    # types:
    #   - WorkflowNode: the root node of a workflow
    #   - OperationNode: a node that performs an operation
    #   - ExpressionNode: a node that evaluates to a value based
    #       on the expression it defines.
    #
    # Node is the root class of all node types and provides the
    # shared implementation and structure.
    #
    # Node subclasses must implement the 2 following methods:
    #   - `check!`: checks the supplied node data to ensure it's
    #     valid,
    #   - `evaluate`: evaluates the node and returns the result
    #     of the evaluation (which depends on the node type).
    #
    # TODO: nodes may have a type attribute for value casting
    class Node
      ERR_MSG_TYPE_UNKNOWN = "the node type \"%s\" is unknown"
      ERR_MSG_TYPE_DOES_NOT_MATCH = "type \"%s\" does not match class %s"
      ERR_MSG_DATA_INVALID_MUST_BE_HASH = "a node must be an hash (%s)"
      ERR_MSG_DATA_INVALID_MISSING_TYPE = "a node must have a `type` attribute (%s)"

      # Build a node according to the specified data. Prior to
      # returning a node instance, it will check that the provided
      # data is valid.
      # The data["type"] attribute is used to build the appropriate
      # type of node.
      def self.build(data:)
        type = data["type"]
        raise(Error, format(ERR_MSG_DATA_INVALID_MISSING_TYPE, data)) if type.nil?
        begin
          node_class = Workflows.const_get("#{type.camelize}Node")
        rescue NameError
          raise(Error, format(ERR_MSG_TYPE_UNKNOWN, type))
        end
        node_class.new(data: data)
      end

      # Loads node subclasses, located in workflows/node directory.
      # Will only load once.
      def self.load_node_classes
        return if @node_classes_loaded
        Dir[File.expand_path("../node/*.rb", __FILE__)].each { |f| require f }
        @node_classes_loaded = true
      end

      load_node_classes

      attr_reader :data

      def initialize(data:)
        @data = data
        check_data!
        check_matching_type!
        check!
      end

      # TODO: rewrite using hooks as advised by Sandi Metz
      # in POODR (raising from the superclass is a smell).
      def evaluate(context:)
        raise "Must be implemented by subclass"
      end

      # TODO: rewrite using hooks as advised by Sandi Metz
      # in POODR (raising from the superclass is a smell).
      def check!
        raise "Must be implemented by subclass"
      end

      private

      def check_data!
        check_data_is_hash!
        check_data_type_present!
      end

      def check_data_is_hash!
        return if data.is_a?(Hash)
        raise_error message: ERR_MSG_DATA_INVALID_MUST_BE_HASH
      end

      def check_data_type_present!
        return unless type.nil?
        raise_error message: ERR_MSG_DATA_INVALID_MISSING_TYPE
      end

      def check_matching_type!
        type_from_class = self.class.name.underscore.split("/").last.sub(/_node\z/, "")
        return unless type != type_from_class
        raise(Error, format(ERR_MSG_TYPE_DOES_NOT_MATCH, type, self.class.name))
      end

      # Helper to raise a Workflows::Node::Error with the specified
      # class and format. The specified format is evaluated using
      # the `format` method, passing the node's `data`.
      #
      # NB: if other arguments for `format` are necessary, you will
      # not be able to use this method.
      #
      # @param error_class: [Error]: optional, defaults to `Node::Error`
      # @param params: [Array]: optional, array of params to pass
      #   to `format` to build the error message. Defaults to `[data]`.
      def raise_error(error_class: Error, message:, params: [data])
        raise(error_class, format(message, *params))
      end

      def type
        data["type"]
      end
    end
  end
end
