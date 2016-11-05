# frozen_string_literal: true
require "spec_helper"
require "rack/test"
require "data/db"
require "sequel"
require "timecop"

require "data/repository"
class SpecRepository < Letto::Data::Repository

end

describe Letto::Data::Repository do
  let(:table) { double("table") }

  describe ".row" do
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

  describe ".insert" do
    before do
      @time = Time.now
      Timecop.freeze(@time)
    end

    after do
      Timecop.return
    end

    it "inserts a row into the db" do
      allow(Letto::Data::Repository).to receive(:table).and_return(table)
      expect(table).
        to receive(:insert).
        with(a: "hello", created_at: @time, updated_at: @time)
      Letto::Data::Repository.insert(a: "hello")
    end
  end

  describe ".delete" do
    it "deletes a row into the db" do
      allow(Letto::Data::Repository).to receive(:where).with(uuid: "1").and_return(table)
      expect(table).
        to receive(:delete).
        with(no_args)
      Letto::Data::Repository.delete(uuid: "1")
    end
  end

  describe ".update_where" do
    it "updates a row into the db" do
      allow(Letto::Data::Repository).to receive(:where).with(uuid: "2").and_return(table)
      expect(table).
        to receive(:update).
        with(uuid: "1")
      Letto::Data::Repository.update_where({ uuid: "2" }, uuid: "1")
    end
  end

  describe ".first_where" do
    it "return the first matching row into the db" do
      allow(Letto::Data::Repository).to receive(:where).with(uuid: "1").and_return(table)
      expect(table).
        to receive(:first).
        with(no_args)
      Letto::Data::Repository.first_where(uuid: "1")
    end
  end

  describe ".where" do
    it "select the rows matching the where condition" do
      allow(Letto::Data::Repository).to receive(:table).and_return(table)
      expect(table).
        to receive(:where).
        with(uuid: "1")
      Letto::Data::Repository.where(uuid: "1")
    end
  end

  describe ".all" do
    it "returns the whole table" do
      allow(Letto::Data::Repository).to receive(:table).and_return(table)
      expect(Letto::Data::Repository.all).to eq(table)
    end
  end

  describe ".table" do
    it "returns the table specs" do
      db = double("db")
      specs_table = double("specs_table")
      allow(Letto::Data::Repository).to receive(:db).and_return(db)
      expect(db).to receive(:[]).with(:specs).and_return(specs_table)
      expect(SpecRepository.table).to eq(specs_table)
    end
  end

  describe ".index" do
    it "returns the entries from the table" do
      entries = double("table.entries")
      allow(Letto::Data::Repository).to receive(:table).and_return(table)
      allow(table).to receive(:entries).and_return(entries)
      expect(Letto::Data::Repository.index).to eq(entries)
    end
  end
end
