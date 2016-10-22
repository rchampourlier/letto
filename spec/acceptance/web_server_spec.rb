# frozen_string_literal: true
require "spec_helper"
require "rack/test"
require "sinatra/sessionography"
require "data/workflow_repository"

# Monkey-patching UsersWebhookCache to prevent
# tests from failing by trying to perform an
# API call to Trello.
require "users_webhooks_cache"
module Letto
  class UsersWebhooksCache
    def self.load(_options)
    end
  end
end

require "letto/web_server"
Letto::WebServer.helpers Sinatra::Sessionography
def app
  Letto::WebServer
end

describe "Letto::WebServer" do
  include Rack::Test::Methods
  let(:workflow) do
    {
      uuid: "1",
      content: JSON.dump(name: "gna")
    }
  end
  before do
    allow(Letto::Data::WorkflowRepository).to receive(:all).and_return(
      [workflow]
    )
    allow(Letto::Data::WorkflowRepository).to receive(:for_uuid).and_return(
      workflow
    )
    get "/workflows/1"
  end


  describe "GET /workflows/1" do
    it "displays the list of workflows" do
      expect(last_response.body).to include("gna")
    end
    it "displays the workflow content in content" do
      expect(last_response.body).to include("\"name\": \"gna\"")
    end
  end

  { put: "/workflows/1", post: "/workflows" }.each do |verb, url|
    describe "#{verb.upcase} #{url}" do
      context "bad formatted JSON" do
        it "displays flash error" do
          send(verb, url, content: "na")
          expect(last_response.body).to include("Invalid JSON: 784: unexpected token at 'na'")
        end
      end

      context "invalid workflow" do
        it "displays flash error" do
          send(verb, url, content: "{}")
          expect(last_response.body).to include("Invalid JSON content: Workflows should have a name")
        end
      end

      context "valid workflow" do
        let(:content) { JSON.dump(name: "gna") }
        it "displays flash notice" do
          allow(Letto::WorkflowsChecker).to receive(:check_workflow).and_return(true)
          if verb == :post
            expect(Letto::Data::WorkflowRepository).
              to receive(:create).
              with(content).
              and_return(1)
          else
            expect(Letto::Data::WorkflowRepository).
              to receive(:update_by_uuid).
              with("1", content: content).
              and_return(true)
          end
          send(verb, url, content: content)
          expect(Sinatra::Sessionography.session[:flash]).to eq(
            success: "Workflow gna saved with id 1"
          )
        end
      end
    end
  end

  describe "DELETE /workflows/1" do
    it "delete the workflow from database" do
      expect(Letto::Data::WorkflowRepository).
        to receive(:delete_by_uuid).
        with("1").
        and_return(true)
      delete "/workflows/1"
    end
  end
end
