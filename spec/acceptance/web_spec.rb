require "spec_helper"
require "rack/test"

require "letto/web"

describe "Letto::Web" do
  include RackTestHelpers

  let(:data) { { test: "data" } }

  describe "GET /" do
    it 'says "ok"' do
      get "/"
      expect(last_response).to be_ok
      expect(last_response.body).to eq({ status: "ok" }.to_json)
    end
  end
end
