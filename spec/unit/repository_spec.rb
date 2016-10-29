# frozen_string_literal: true
require "spec_helper"
require "rack/test"
require "data/db"
require "sequel"

require "data/repository"
describe "Letto::Data::Repository" do
  describe "row" do
    before(:all) do
      @time = Time.now
      @val = Letto::Data::Repository.row({ test: "val" }, @time)
    end

    it "adds a created_at field to a row" do
      expect(@val).to have_key(:created_at)
    end
    it "adds a updated_at field to a row" do
      expect(@val).to have_key(:updated_at)
    end
    it "has both created_at and updated_at fields matching with time" do
      expect(@val[:created_at]).to eq(@val[:updated_at])
      expect(@val[:created_at]).to eq(@time)
    end
  end

  describe "insert" do
    it "inserts a row into the db" do
      a = nil
      allow(Letto::Data::Repository).to receive(:table).and_return(a)
      expect(a).
        to receive(:insert).
        with(a: "hello", created_at: Time.now, updated_at: Time.now)
      Letto::Data::Repository.insert(a: "hello")
    end
  end

  describe "delete" do
    it "deletes a row into the db" do
      a = nil
      allow(Letto::Data::Repository).to receive(:table).and_return(a)
      expect(a).
        to receive(:where).
        with(uuid: "1").
        and_return(a)
      expect(a).
        to receive(:delete).
        with(no_args)
      Letto::Data::Repository.delete(uuid: "1")
    end
  end

  describe "update_where" do
    it "updates a row into the db" do
      a = nil
      allow(Letto::Data::Repository).to receive(:table).and_return(a)
      expect(a).
        to receive(:where).
        with(uuid: "1").
        and_return(a)
      expect(a).
        to receive(:update).
        with(uuid: "2")
      Letto::Data::Repository.update({ uuid: "2" }, uuid: "1")
    end
  end

  describe "first_where" do
    it "return the first matching row into the db" do
      a = nil
      allow(Letto::Data::Repository).to receive(:table).and_return(a)
      expect(a).
        to receive(:where).
        with(uuid: "1").
        and_return(a)
      expect(a).
        to receive(:first).
        with(no_args)
      Letto::Data::Repository.first(uuid: "1")
    end
  end

  describe "all" do

  end

  describe "table" do

  end

  describe "index" do

  end
end
