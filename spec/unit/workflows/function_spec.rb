# frozen_string_literal: true
require "spec_helper"
require "letto/workflows/function"

module Letto
  module Workflows
    module Function
      class SpecFunction < Base
      end
    end
  end
end

describe Letto::Workflows::Function do

  it "loads all functions defined in workflows/function" do
    files = Dir[File.expand_path("../../../../lib/letto/workflows/function/*.rb", __FILE__)]
    functions = files.map { |f| f.split("/").last.gsub(/\.rb\z/, "").camelize }
    functions.each do |function|
      expect { described_class.const_get(function) }.not_to raise_error
    end
  end

  describe ".for_name(function_name)" do

    subject do
      described_class.for_name(name: function_name)
    end

    context "the function exists" do
      let(:function_name) { :spec_function }

      it "returns the correct function's class" do
        expect(subject).to eq(Letto::Workflows::Function::SpecFunction)
      end
    end

    context "the function does not exist" do
      let(:function_name) { :unknown_function }

      it "raises a NameError" do
        expect { subject }.to raise_error(NameError)
      end
    end
  end
end
