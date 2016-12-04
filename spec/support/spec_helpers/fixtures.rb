# frozen_string_literal: true
module SpecHelpers

  # Fixtures for specs
  module Fixtures

    def workflow(valid: true)
      valid ? workflow_valid : workflow_invalid
    end

    def workflow_valid
      {
        "name" => "valid workflow",
        "type" => "workflow",
        "condition" => {
          "type" => "expression",
          "value_type" => "value",
          "value" => true
        },
        "action" => {
          "type" => "operation",
          "function" => "log",
          "arguments" => {
            "message" => {
              "type" => "expression",
              "value_type" => "value",
              "value" => "{{ payload.value }}"
            }
          }
        }
      }
    end

    def workflow_invalid
      {
        "name" => "invalid workflow"
      }
    end

    def expression(value:)
      {
        "type" => "expression",
        "value" => value
      }
    end

    def condition(true_condition: true)
      {
        "type" => "operation",
        "function" => "string_comparison",
        "arguments" => {
          "string1" => expression(value: "abc"),
          "string2" => expression(value: true_condition ? "abc" : "bcd")
        }
      }
    end

    def action
      {
        "type" => "operation",
        "function" => "log",
        "arguments" => {
          "message" => "basic workflow action"
        }
      }
    end
  end
end
