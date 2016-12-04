# frozen_string_literal: true
require "spec_helper"
require "rack/test"
require "persistence/user_repository"

describe "Letto::Persistence::UserRepository" do

  describe "create" do
    it "calls insert with specified arguments" do
      allow(Letto::Persistence::Repository).to receive(:generate_uuid).and_return("1")
      expect(Letto::Persistence::Repository).
        to receive(:insert).
        with(
          uuid: "1",
          username: "me",
          trello_access_token: "trello_access_token",
          trello_access_token_secret: "trello_access_token_secret",
          session_id: "session_id"
        )
      Letto::Persistence::UserRepository.create(
        username: "me",
        trello_access_token: "trello_access_token",
        trello_access_token_secret: "trello_access_token_secret",
        session_id: "session_id"
      )
    end
  end

  describe "for_session_id" do
    it "calls first_where with session_id" do
      expect(Letto::Persistence::Repository).
        to receive(:first_where).
        with(session_id: "session_id")
      Letto::Persistence::UserRepository.for_session_id("session_id")
    end
  end

  describe "update_by_uuid(uuid:, access_token: nil, access_token_secret: nil)" do

    it "updates the specified attributes" do
      expect(Letto::Persistence::Repository).
        to receive(:update_where).
        with({ uuid: "1" }, trello_access_token: "new")
      Letto::Persistence::UserRepository.update_by_uuid(uuid: "1", trello_access_token: "new")
    end
  end

  describe "delete_by_uuid(uuid:)" do
    it "calls delete with uuid" do
      expect(Letto::Persistence::Repository).
        to receive(:delete).
        with(uuid: "1")
      Letto::Persistence::UserRepository.delete_by_uuid(uuid: "1")
    end
  end
end
