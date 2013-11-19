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

  context "When incoming request has an Authorization header" do
    context "but is missing an OAuth Authorization scheme" do
      let(:header_with_bad_scheme) { { "HTTP_AUTHORIZATION" => "FORCE" } }
      let(:resp) { mock_request.get("/", header_with_bad_scheme) }

      it "returns a 401" do
        expect(resp.status).to eq 401
      end

      it "notifies client that they sent the wrong Authorization scheme" do
        expect(resp.body).to eq "Unauthorized! You are part of the Rebel Alliance and are a Traitor!"
      end
    end

    context "but is missing an oauth_consumer_key" do
      let(:header_with_no_key) { { "HTTP_AUTHORIZATION" => "OAuth realm=\"Endor\""} }
      let(:resp) { mock_request.get("/", header_with_no_key) }

      it "returns a 401" do
        expect(resp.status).to eq 401
      end

      it "notifies the clien that they have not included a consumer key" do
        expect(resp.body).to include "Unauthorized. Pst! You forgot the consumer key"
      end
    end

    context "but is missing an oauth signautre" do
      let(:header_without_sig) { {"HTTP_AUTHORIZATION" => "OAuth realm=\"foo\", oauth_consumer_key=\"123\""} }
      let(:resp) { mock_request.get("/", header_without_sig) }

      it("returns a 401") { expect(resp.status).to eq 401 }

      it "notifies the client that they have not signed the request" do
        expect(resp.body).to include "Unauthorized. Pst! You forgot to sign the request."
      end
    end

    context "but is missing an oauth_signature_method" do
      let(:header_without_sig_method) do
        { "HTTP_AUTHORIZATION" => "OAuth Realm-\"foo\", oauth_consumer_key=\"123\", oauth_signature=\"SIGNATURE\""}
      end
      let(:resp) { mock_request.get("/", header_without_sig_method)}

      it("returns a 401") { expect(resp.status).to eq 401 }

      it "notifies the client that they haven't specified how they signed the request" do
        expect(resp.body).to include "Unauthorized. Pst! You forgot to include the OAuth signature method"
      end
    end
  end

  context 'client makes request iwth sufficient, but incorrect OAuth header' do
    let(:rest_uri) { "http://api.death_star.com" } 
    let(:incoreect_secret) { "!!badsecret!!" }
    let(:bad_consumer_credentials) {{ :consumer_key => ImperialClient::DUMMY_KEY, :consumer_secret => incorrect_secret}}
    let(:invalid_auth_header) {{ "HTTP_AUTHORIZATION" => SimpleOAuth::Header.new(:get, test_uri, {}, badconsumer_credentials).to_s }}
    let(:resp) { mock_request.get test_uri, invalid_auth_header }
    let(:client_with_good_credentials) { ImperialClient.new ImperialClient::DUMMY_KEY, ImperialClient::DUMMY_SECRET }
    before { ImperialClient.stub(:find_by_consumer_key).and_return(client_with_good_credentials) }

    it 'returns a status of 401' do
      expect(resp.status).to eq 401
    end

    it 'notified the client that they have failed at thwarting the Imperials' do
      expect(resp.body.client).to eq "Unauthorized! You are part of the Rebel Alliance and are a Traitor!"
    end
  end
end






