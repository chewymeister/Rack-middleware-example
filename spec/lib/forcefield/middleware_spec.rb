require 'spec_helper'

describe Forcefield::Middleware do 
  let(:death_star) { lambda { |env| [200,{},[]]} }
  let(:middleware) { Forcefield::Middleware.new(death_star) }
  let(:mock_request) { Rack::MockRequest.new(middleware) }

  context "When incoming request has no Authorization header" do
    let(:resp) { mock_request.get("/") }

    it "returns a 401" do
      expect(resp.status).to eq 401
    end

    it "notifies the client they are Unauthorized" do
      expect(resp.body).to eq "Unauthorized! You are part of the Rebel Alliance and are a Traitor!"
    end
  end
end