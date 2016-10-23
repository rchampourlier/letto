# frozen_string_literal: true
require "spec_helper"
require "rack/test"

require "data/user_repository"
describe "Letto::Data::UserRepository" do
  describe "create" do
    it "calls insert with specified arguments" do
      allow(Letto::Data::Repository).to receive(:generate_uuid).and_return("1")
      expect(Letto::Data::Repository).
        to receive(:insert).
        with(
          uuid: "1",
          username: "me",
          trello_access_token: "access_token",
          trello_access_token_secret: "access_token_secret",
          session_id: "session_id"
        )
      Letto::Data::UserRepository.create("me", "access_token", "access_token_secret", "session_id")
    end
  end

  describe "for_session_id" do
    it "calls first_where with session_id" do
      expect(Letto::Data::Repository).
        to receive(:first_where).
        with(session_id: "session_id")
      Letto::Data::UserRepository.for_session_id("session_id")
    end
  end

  describe "update_by_uuid" do
    it "calls update_where with uuid" do
      expect(Letto::Data::Repository).
        to receive(:update_where).
        with({ uuid: "1" }, uuid: "2")
      Letto::Data::UserRepository.update_by_uuid("1", uuid: "2")
    end
  end

  describe "delete_by_uuid" do
    it "calls delete with uuid" do
      expect(Letto::Data::Repository).
        to receive(:delete).
        with(uuid: "1")
      Letto::Data::UserRepository.delete_by_uuid("1")
    end
  end
end
