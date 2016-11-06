# frozen_string_literal: true
require "spec_helper"
require "rack/test"

require "workflows_checker"
describe "Letto::WorkflowsChecker" do
  let(:test_wf) { {} }
  context ".check_workflows" do
    it "raises an error if there is no workflow to check" do
      expect {
        Letto::WorkflowsChecker.check_workflows!(nil)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          Letto::WorkflowsChecker::ERR_MSG_NO_WORKFLOWS
        )
    end
  end

  context ".check_workflow" do
    it "raises an error if the workflow does not have any name" do
      expect {
        Letto::WorkflowsChecker.check_workflow!(test_wf)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          Letto::WorkflowsChecker::ERR_MSG_NO_NAME
        )
    end

    it "raises an error if the workflow does not have a condition block" do
      test_wf = { "name" => "x" }
      expect {
        Letto::WorkflowsChecker.check_workflow!(test_wf)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          format(Letto::WorkflowsChecker::ERR_MSG_NO_CONDITIONS, test_wf["name"])
        )
    end

    it "raises an error if the workflow does not have an array as condition block" do
      test_wf = {
        "name" => "x",
        "conditions" => 1
      }
      expect {
        Letto::WorkflowsChecker.check_workflow!(test_wf)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          format(Letto::WorkflowsChecker::ERR_MSG_CONDITIONS_IS_NOT_ARRAY, test_wf["name"])
        )
    end

    it "raises an error if the workflow does not have a condition on model.id" do
      test_wf = {
        "name" => "x",
        "conditions" => [
          "path" => "a"
        ]
      }
      expect {
        Letto::WorkflowsChecker.check_workflow!(test_wf)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          format(Letto::WorkflowsChecker::ERR_MSG_CONDITIONS_HAS_NONE_ON_MODEL_ID, test_wf["name"])
        )
    end

    it "raises an error if the comparison type is not present" do
      test_wf = {
        "name" => "x",
        "conditions" => [{ "path" => "model.id" }]
      }
      expect {
        Letto::WorkflowsChecker.check_workflow!(test_wf)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          format(Letto::WorkflowsChecker::ERR_MSG_COMPARISON_TYPE_NOT_SUPPORTED, "")
        )
    end

    it "raises an error if the comparison type is not supported" do
      test_wf = {
        "name" => "x",
        "conditions" => [
          {
            "type" => "a",
            "path" => "model.id"
          }
        ]
      }
      expect {
        Letto::WorkflowsChecker.check_workflow!(test_wf)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          format(Letto::WorkflowsChecker::ERR_MSG_COMPARISON_TYPE_NOT_SUPPORTED, test_wf["conditions"][0]["type"])
        )
    end

    it "raises an error if the workflow does not have an action block" do
      test_wf = {
        "name" => "x",
        "conditions" => [
          {
            "type" => "string_comparison",
            "path" => "model.id"
          }
        ]
      }
      expect {
        Letto::WorkflowsChecker.check_workflow!(test_wf)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          format(Letto::WorkflowsChecker::ERR_MSG_NO_ACTION, test_wf["name"])
        )
    end
  end

  context ".check_block" do
    it "raises an error if block has no type" do
      expect {
        Letto::WorkflowsChecker.check_block!(test_wf)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_NO_TYPE, test_wf)
        )
    end

    it "raises an error if block type is not supported" do
      test_wf = {
        "type" => "x"
      }
      expect {
        Letto::WorkflowsChecker.check_block!(test_wf)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          format(Letto::WorkflowsChecker::ERR_MSG_NODE_TYPE_NOT_SUPPORTED, test_wf["type"])
        )
    end

    it "raises an error if block is not of type operation and has no value" do
      test_wf = {
        "type" => "expression"
      }
      expect {
        Letto::WorkflowsChecker.check_block!(test_wf)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_NO_VALUE, test_wf)
        )
    end
  end

  context ".check_block_operation" do
    it "raises an error if there is no function name" do
      expect {
        Letto::WorkflowsChecker.check_block_operation!(test_wf)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_NO_FUNCTION, test_wf)
        )
    end

    it "raises an error if the function name is not supported" do
      test_wf = {
        "function" => "x"
      }
      expect {
        Letto::WorkflowsChecker.check_block_operation!(test_wf)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          format(Letto::WorkflowsChecker::ERR_MSG_FUNCTION_NOT_SUPORTED, test_wf["function"])
        )
    end

    it "raises an error if the block has no arguments" do
      test_wf = {
        "function" => "add"
      }
      expect {
        Letto::WorkflowsChecker.check_block_operation!(test_wf)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_NO_ARGUMENTS, test_wf)
        )
    end

    it "raises an error if arguments is not an array" do
      test_wf = {
        "function" => "add",
        "arguments" => "x"
      }
      expect {
        Letto::WorkflowsChecker.check_block_operation!(test_wf)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_ARGUMENT_IS_NOT_ARRAY, test_wf)
        )
    end
  end

  context ".check_block_operation_api_call" do
    it "raises an error if the 1st argument value is not a supported verb" do
      test_wf = {
        "arguments" => [
          {
            "type" => "expression",
            "value" => "x"
          },
          "y",
          "z"
        ]
      }
      expect {
        Letto::WorkflowsChecker.check_block_operation_api_call!(test_wf)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          format(Letto::WorkflowsChecker::ERR_MSG_VERB_NOT_SUPPORTED, test_wf["arguments"][0]["value"])
        )
    end

    it "raises no error if the arguments are of good type" do
      test_wf = {
        "arguments" => [
          {
            "type" => "expression",
            "value" => "GET"
          },
          {
            "type" => "expression"
          },
          {
            "type" => "payload"
          }
        ]
      }
      expect {
        Letto::WorkflowsChecker.check_block_operation_api_call!(test_wf)
      }.
        not_to raise_error
    end
  end

  context ".check_block_operation_convert" do
    it "raises an error if the 1st argument value is not a supported conversion function" do
      test_wf = {
        "arguments" => [
          {
            "type" => "expression",
            "value" => "x"
          },
          "y"
        ]
      }
      expect {
        Letto::WorkflowsChecker.check_block_operation_convert!(test_wf)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          format(Letto::WorkflowsChecker::ERR_MSG_CONVERSION_FUNCTION_NOT_SUPPORTED, test_wf["arguments"][0]["value"])
        )
    end

    it "raises no error if the arguments are of good type" do
      test_wf = {
        "arguments" => [
          {
            "type" => "expression",
            "value" => "String"
          },
          {
            "type" => "expression"
          }
        ]
      }
      expect {
        Letto::WorkflowsChecker.check_block_operation_convert!(test_wf)
      }.
        not_to raise_error
    end
  end

  context ".check_block_operation_gsub" do
    it "raises an error if the 2nd argument value is not a supported comparison type" do
      test_wf = {
        "arguments" => [
          {
            "type" => "expression",
            "value" => "x"
          },
          {
            "type" => "expression",
            "value" => "x"
          },
          {
            "type" => "expression",
            "value" => "x"
          },
          {
            "type" => "expression",
            "value" => "x"
          }
        ]
      }
      expect {
        Letto::WorkflowsChecker.check_block_operation_gsub!(test_wf)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          format(Letto::WorkflowsChecker::ERR_MSG_COMPARISON_TYPE_NOT_SUPPORTED, test_wf["arguments"][1]["value"])
        )
    end

    it "raises no error if the arguments are of good type" do
      test_wf = {
        "arguments" => [
          {
            "type" => "expression",
            "value" => "String"
          },
          {
            "type" => "expression",
            "value" => "string_comparison"
          },
          {
            "type" => "expression",
            "value" => "x"
          },
          {
            "type" => "expression",
            "value" => "x"
          }
        ]
      }
      expect {
        Letto::WorkflowsChecker.check_block_operation_gsub!(test_wf)
      }.
        not_to raise_error
    end
  end

  context ".check_block_operation_arguments" do
    it "return with a name error if the function args are undefined" do
      block = {
        "function" => "na",
        "arguments" => []
      }
      expect {
        Letto::WorkflowsChecker.check_block_operation_arguments(block)
      }.
      to raise_error(
        NameError
      )
    end
  end

  context ".check_block_operation_arguments_nb" do
    context "static number of args" do
      let(:function) { "TEST" }
      let(:constraints) { %w(* *).freeze }
      let(:block) { "" }

      it "raises an error if there is less args" do
        arguments = [
          {
            "type" => "expression",
            "value" => "String"
          }
        ]
        expect {
          Letto::WorkflowsChecker.check_block_operation_arguments_nb!(function, arguments, constraints, block)
        }.
          to raise_error(
            Letto::WorkflowsChecker::Error,
            format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_WRONG_NB_ARGS, function, 2, block)
          )
      end

      it "raises no error if there is the good number of args" do
        arguments = [
          {
            "type" => "expression",
            "value" => "String"
          },
          {
            "type" => "expression",
            "value" => "String"
          }
        ]
        expect {
          Letto::WorkflowsChecker.check_block_operation_arguments_nb!(function, arguments, constraints, block)
        }.
          not_to raise_error
      end

      it "raises an error if there is more args" do
        arguments = [
          {
            "type" => "expression",
            "value" => "String"
          },
          {
            "type" => "expression",
            "value" => "String"
          },
          {
            "type" => "expression",
            "value" => "String"
          }
        ]
        expect {
          Letto::WorkflowsChecker.check_block_operation_arguments_nb!(function, arguments, constraints, block)
        }.
          to raise_error(
            Letto::WorkflowsChecker::Error,
            format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_WRONG_NB_ARGS, function, 2, block)
          )
      end
    end

    context "static number of args with optional arg" do
      let(:function) { "TEST" }
      let(:constraints) { %w(* * [*]).freeze }
      let(:block) { "" }

      it "raises an error if there is less args" do
        arguments = [
          {
            "type" => "expression",
            "value" => "String"
          }
        ]
        expect {
          Letto::WorkflowsChecker.check_block_operation_arguments_nb!(function, arguments, constraints, block)
        }.
          to raise_error(
            Letto::WorkflowsChecker::Error,
            format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_WRONG_NB_ARGS, function, "between 2 and 3", block)
          )
      end

      it "raises no error if there is the good number of args - no optional arg" do
        arguments = [
          {
            "type" => "expression",
            "value" => "String"
          },
          {
            "type" => "expression",
            "value" => "String"
          }
        ]
        expect {
          Letto::WorkflowsChecker.check_block_operation_arguments_nb!(function, arguments, constraints, block)
        }.
          not_to raise_error
      end

      it "raises no error if there is the good number of args - with optional arg" do
        arguments = [
          {
            "type" => "expression",
            "value" => "String"
          },
          {
            "type" => "expression",
            "value" => "String"
          },
          {
            "type" => "expression",
            "value" => "String"
          }
        ]
        expect {
          Letto::WorkflowsChecker.check_block_operation_arguments_nb!(function, arguments, constraints, block)
        }.
          not_to raise_error
      end

      it "raises an error if there is more args" do
        arguments = [
          {
            "type" => "expression",
            "value" => "String"
          },
          {
            "type" => "expression",
            "value" => "String"
          },
          {
            "type" => "expression",
            "value" => "String"
          },
          {
            "type" => "expression",
            "value" => "String"
          }
        ]
        expect {
          Letto::WorkflowsChecker.check_block_operation_arguments_nb!(function, arguments, constraints, block)
        }.
          to raise_error(
            Letto::WorkflowsChecker::Error,
            format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_WRONG_NB_ARGS, function, "between 2 and 3", block)
          )
      end
    end

    context "variable number of args" do
      let(:function) { "TEST" }
      let(:constraints) { %w(* * ...).freeze }
      let(:block) { "" }

      it "raises an error if there is not enough args" do
        arguments = [
          {
            "type" => "expression",
            "value" => "String"
          }
        ]
        expect {
          Letto::WorkflowsChecker.check_block_operation_arguments_nb!(function, arguments, constraints, block)
        }.
          to raise_error(
            Letto::WorkflowsChecker::Error,
            format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_WRONG_NB_ARGS, function, "at least 2", block)
          )
      end

      it "raises no error if there is the minimum number of args" do
        arguments = [
          {
            "type" => "expression",
            "value" => "String"
          },
          {
            "type" => "expression",
            "value" => "String"
          }
        ]
        expect {
          Letto::WorkflowsChecker.check_block_operation_arguments_nb!(function, arguments, constraints, block)
        }.
          not_to raise_error
      end

      it "raises no error if there is more than the minimal" do
        arguments = [
          {
            "type" => "expression",
            "value" => "String"
          },
          {
            "type" => "expression",
            "value" => "String"
          },
          {
            "type" => "expression",
            "value" => "String"
          }
        ]
        expect {
          Letto::WorkflowsChecker.check_block_operation_arguments_nb!(function, arguments, constraints, block)
        }.
          not_to raise_error
      end
    end
  end

  context ".check_block_operation_arguments_types" do
    let(:function) { "TEST" }
    let(:constraints) { %w(expression [payload] ...).freeze }
    let(:block) { "" }

    it "raises an error if the first argument is not an expression" do
      arguments = [
        {
          "type" => "payload",
          "value" => "String"
        }
      ]
      expect {
        Letto::WorkflowsChecker.check_block_operation_arguments_types!(function, arguments, constraints, block)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_ARG_WRONG_TYPE, 1, "expression", function, block)
        )
    end

    it "raises no error if the first argument is an expression - no other args" do
      arguments = [
        {
          "type" => "expression",
          "value" => "String"
        }
      ]
      expect {
        Letto::WorkflowsChecker.check_block_operation_arguments_types!(function, arguments, constraints, block)
      }.
        not_to raise_error
    end

    it "raises an error if the second argument is not a payload" do
      arguments = [
        {
          "type" => "expression",
          "value" => "String"
        },
        {
          "type" => "expression",
          "value" => "String"
        }
      ]
      expect {
        Letto::WorkflowsChecker.check_block_operation_arguments_types!(function, arguments, constraints, block)
      }.
        to raise_error(
          Letto::WorkflowsChecker::Error,
          format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_ARG_WRONG_TYPE, 2, "payload", function, block)
        )
    end

    it "raises no error if the second argument is a payload" do
      arguments = [
        {
          "type" => "expression",
          "value" => "String"
        },
        {
          "type" => "payload",
          "value" => "String"
        }
      ]
      expect {
        Letto::WorkflowsChecker.check_block_operation_arguments_types!(function, arguments, constraints, block)
      }.
        not_to raise_error
    end

    it "raises no error whatever the type of the third arg" do
      arguments = [
        {
          "type" => "expression",
          "value" => "String"
        },
        {
          "type" => "payload",
          "value" => "String"
        },
        {
          "type" => "x",
          "value" => "String"
        }
      ]
      expect {
        Letto::WorkflowsChecker.check_block_operation_arguments_types!(function, arguments, constraints, block)
      }.
        not_to raise_error
    end
  end
end
