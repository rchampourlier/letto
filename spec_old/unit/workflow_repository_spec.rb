# frozen_string_literal: true
require "spec_helper"
require "persistence/workflow_repository"

describe "Letto::Persistence::WorkflowRepository" do

  describe "create(user_uuid:, data:)" do
    it "calls insert with specified arguments" do
      allow(Letto::Persistence::Repository).to receive(:generate_id).and_return("1")
      expect(Letto::Persistence::Repository).
        to receive(:insert).
        with(
          id: "1",
          user_uuid: "id",
          data: "data"
        )
      Letto::Persistence::WorkflowRepository.create(user_uuid: "id", data: "data")
    end
  end

  describe "for_id" do
    it "calls first_where with id" do
      expect(Letto::Persistence::Repository).
        to receive(:first_where).
        with(id: "id")
      Letto::Persistence::WorkflowRepository.for_id("id")
    end
  end

  describe "update_by_id(id:, data:)" do

    it "updates the `data` field" do
      expect(Letto::Persistence::Repository).
        to receive(:update_where).
        with({ id: "1" }, data: "new")
      Letto::Persistence::WorkflowRepository.update_by_id(id: "1", data: "new")
    end
  end

  describe "delete_by_id(id:)" do
    it "calls delete with id" do
      expect(Letto::Persistence::Repository).
        to receive(:delete).
        with(id: "1")
      Letto::Persistence::WorkflowRepository.delete_by_id(id: "1")
    end
  end
end
