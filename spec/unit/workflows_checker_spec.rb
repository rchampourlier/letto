# frozen_string_literal: true
require "spec_helper"
require "rack/test"

require "workflows_checker"
describe "Letto::WorkflowsChecker" do
  let(:test_wf) { {} }
  context "check_workflows" do
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

  context "check_workflow" do
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

    it "raises an error if the workflow does not have an action block" do
      test_wf = {
        "name" => "x",
        "conditions" => [{ "path" => "model.id" }]
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

  context "check_block" do
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

  context "check_block_operation" do
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

  context "check_block_operation_api_call" do
    context "check number of orguments" do
      it "raises an error if there is less than 2 argument" do
        test_wf = {
          "arguments" => ["x"]
        }
        expect {
          Letto::WorkflowsChecker.check_block_operation_api_call!(test_wf)
        }.
          to raise_error(
            Letto::WorkflowsChecker::Error,
            format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_WRONG_NB_ARGS, "api_call", "2 or 3", test_wf)
          )
      end

      it "raises an error if there is more than 3 arguments" do
        test_wf = {
          "arguments" => %w(w x y z)
        }
        expect {
          Letto::WorkflowsChecker.check_block_operation_api_call!(test_wf)
        }.
          to raise_error(
            Letto::WorkflowsChecker::Error,
            format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_WRONG_NB_ARGS, "api_call", "2 or 3", test_wf)
          )
      end

      it "does not raise an error on the number of arguments if there is 2 arguments" do
        test_wf = {
          "arguments" => %w(x y)
        }
        expect {
          Letto::WorkflowsChecker.check_block_operation_api_call!(test_wf)
        }.
          to raise_error(
            Letto::WorkflowsChecker::Error,
            format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_ARG_WRONG_TYPE, 1, "expression", "api_call", test_wf)
          )
      end

      it "does not raise an error on the number of arguments if there is 3 arguments" do
        test_wf = {
          "arguments" => %w(x y z)
        }
        expect {
          Letto::WorkflowsChecker.check_block_operation_api_call!(test_wf)
        }.
          to raise_error(
            Letto::WorkflowsChecker::Error,
            format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_ARG_WRONG_TYPE, 1, "expression", "api_call", test_wf)
          )
      end
    end

    context "check arguments types" do
      test_wf = {
        "arguments" => [
          { "type" => "x" },
          "y",
          "z"
        ]
      }
      it "raises an error if the 1st argument is not of type expression" do
        expect {
          Letto::WorkflowsChecker.check_block_operation_api_call!(test_wf)
        }.
          to raise_error(
            Letto::WorkflowsChecker::Error,
            format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_ARG_WRONG_TYPE, 1, "expression", "api_call", test_wf)
          )
      end

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

      it "raises an error if the 2nd argument is not of type expression" do
        test_wf = {
          "arguments" => [
            {
              "type" => "expression",
              "value" => "GET"
            },
            {
              "type" => "y"
            },
            "z"
          ]
        }
        expect {
          Letto::WorkflowsChecker.check_block_operation_api_call!(test_wf)
        }.
          to raise_error(
            Letto::WorkflowsChecker::Error,
            format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_ARG_WRONG_TYPE, 2, "expression", "api_call", test_wf)
          )
      end

      it "raises an error if the 3rd argument is not of type payload" do
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
              "type" => "z"
            }
          ]
        }
        expect {
          Letto::WorkflowsChecker.check_block_operation_api_call!(test_wf)
        }.
          to raise_error(
            Letto::WorkflowsChecker::Error,
            format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_ARG_WRONG_TYPE, 3, "payload", "api_call", test_wf)
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
  end

  context "check_block_operation_convert" do
    context "check number of orguments" do
      it "raises an error if there is less than 2 argument" do
        test_wf = {
          "arguments" => ["x"]
        }
        expect {
          Letto::WorkflowsChecker.check_block_operation_convert!(test_wf)
        }.
          to raise_error(
            Letto::WorkflowsChecker::Error,
            format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_WRONG_NB_ARGS, "convert", "2", test_wf)
          )
      end

      it "raises an error if there is more than 2 arguments" do
        test_wf = {
          "arguments" => %w(x y z)
        }
        expect {
          Letto::WorkflowsChecker.check_block_operation_convert!(test_wf)
        }.
          to raise_error(
            Letto::WorkflowsChecker::Error,
            format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_WRONG_NB_ARGS, "convert", "2", test_wf)
          )
      end

      it "does not raise an error on the number of arguments if there is 2 arguments" do
        test_wf = {
          "arguments" => %w(x y)
        }
        expect {
          Letto::WorkflowsChecker.check_block_operation_convert!(test_wf)
        }.
          to raise_error(
            Letto::WorkflowsChecker::Error,
            format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_ARG_WRONG_TYPE, 1, "expression", "convert", test_wf)
          )
      end
    end

    context "check arguments types" do
      it "raises an error if the 1st argument is not of type expression" do
        test_wf = {
          "arguments" => [
            { "type" => "x" },
            "y"
          ]
        }
        expect {
          Letto::WorkflowsChecker.check_block_operation_convert!(test_wf)
        }.
          to raise_error(
            Letto::WorkflowsChecker::Error,
            format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_ARG_WRONG_TYPE, 1, "expression", "convert", test_wf)
          )
      end

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

      it "raises an error if the 2nd argument is not of type expression" do
        test_wf = {
          "arguments" => [
            {
              "type" => "expression",
              "value" => "String"
            },
            {
              "type" => "y"
            }
          ]
        }
        expect {
          Letto::WorkflowsChecker.check_block_operation_convert!(test_wf)
        }.
          to raise_error(
            Letto::WorkflowsChecker::Error,
            format(Letto::WorkflowsChecker::ERR_MSG_BLOCK_OPERATION_ARG_WRONG_TYPE, 2, "expression", "convert", test_wf)
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
  end
end
