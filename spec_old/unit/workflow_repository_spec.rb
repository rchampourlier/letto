# frozen_string_literal: true
require "spec_helper"
require "persistence/workflow_repository"

describe "Letto::Persistence::WorkflowRepository" do

  describe "create(user_uuid:, data:)" do
    it "calls insert with specified arguments" do
      allow(Letto::Persistence::Repository).to receive(:generate_uuid).and_return("1")
      expect(Letto::Persistence::Repository).
        to receive(:insert).
        with(
          uuid: "1",
          user_uuid: "uuid",
          data: "data"
        )
      Letto::Persistence::WorkflowRepository.create(user_uuid: "uuid", data: "data")
    end
  end

  describe "for_uuid" do
    it "calls first_where with uuid" do
      expect(Letto::Persistence::Repository).
        to receive(:first_where).
        with(uuid: "uuid")
      Letto::Persistence::WorkflowRepository.for_uuid("uuid")
    end
  end

  describe "update_by_uuid(uuid:, data:)" do

    it "updates the `data` field" do
      expect(Letto::Persistence::Repository).
        to receive(:update_where).
        with({ uuid: "1" }, data: "new")
      Letto::Persistence::WorkflowRepository.update_by_uuid(uuid: "1", data: "new")
    end
  end

  describe "delete_by_uuid(uuid:)" do
    it "calls delete with uuid" do
      expect(Letto::Persistence::Repository).
        to receive(:delete).
        with(uuid: "1")
      Letto::Persistence::WorkflowRepository.delete_by_uuid(uuid: "1")
    end
  end
end
