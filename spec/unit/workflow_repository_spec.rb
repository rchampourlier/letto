# frozen_string_literal: true
require "spec_helper"
require "rack/test"

require "data/workflow_repository"
describe "Letto::Data::WorkflowRepository" do
  describe "create" do
    it "calls insert with specified arguments" do
      allow(Letto::Data::Repository).to receive(:generate_uuid).and_return("1")
      expect(Letto::Data::Repository).
        to receive(:insert).
        with(
          uuid: "1",
          content: "content"
        )
      Letto::Data::WorkflowRepository.create("content")
    end
  end

  describe "for_uuid" do
    it "calls first_where with uuid" do
      expect(Letto::Data::Repository).
        to receive(:first_where).
        with(uuid: "uuid")
      Letto::Data::WorkflowRepository.for_uuid("uuid")
    end
  end

  describe "update_by_uuid" do
    it "calls update_where with uuid" do
      expect(Letto::Data::Repository).
        to receive(:update_where).
        with({ uuid: "1" }, uuid: "2")
      Letto::Data::WorkflowRepository.update_by_uuid("1", uuid: "2")
    end
  end

  describe "delete_by_uuid" do
    it "calls delete with uuid" do
      expect(Letto::Data::Repository).
        to receive(:delete).
        with(uuid: "1")
      Letto::Data::WorkflowRepository.delete_by_uuid("1")
    end
  end
end
