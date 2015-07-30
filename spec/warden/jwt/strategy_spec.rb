require 'spec_helper'
require 'warden/jwt'

describe Warden::JWT::Strategy do
  let(:strategy) { Warden::Strategies[:jwt].new(env_with_params(path, params, env), warden_scope) }

  let(:warden_scope) { :test_scope }

  let(:env) do
    { 'warden' => double(:config => warden_config) }
  end

  let(:warden_config) do
    { :scope_defaults => { warden_scope => { :config => scope_config } } }
  end

  let(:secret) { '1fcd5a60e0f8f874c9297d7bc9e8af21a1e8be86add775fcaa1ed8a3722089f398a4ef6fa8a0cc115b85557a72920feaf894e4a34dc3f87dbf91d95f398b5c4c' }
  let(:issuer) { 'http://localhost:4000'}
  let(:audience) { '1f24bf542b6925ff3b18032f9311c122c21068ce0a09033b207112f826db3d7f' }
  let(:verify_audience) { false }
  let(:verify_issuer) { false }
  let(:client_options) { {} }

  let(:scope_config) do
    {
      :issuer => issuer,
      :audience => audience,
      :secret => secret,
      :verify_audience => verify_audience,
      :verify_issuer => verify_issuer,
      :client_options => client_options
    }
  end

  let(:params) { {} }

  let(:path) { '/' }

  before(:each) do
    RAS = Warden::Strategies unless defined?(RAS)
    Warden::Strategies.clear!
    Warden::Strategies.add(:jwt, Warden::JWT::Strategy)
  end

  describe "#valid?" do
    context "with empty params" do
      let(:params) { {} }

      it "is false" do
        expect(strategy.valid?).to eq(false)
      end
    end

    context "with only username param" do
      let(:params) { {'username' => 'user'} }

      it "is false" do
        expect(strategy.valid?).to eq(false)
      end
    end

    context "with only password param" do
      let(:params) { {'password' => 'pass'} }

      it "is false" do
        expect(strategy.valid?).to eq(false)
      end
    end

    context "with username and password" do
      let(:params) { {'username' => 'user', 'password' => 'pass'} }

      it "is true" do
        expect(strategy.valid?).to eq(true)
      end
    end
  end

  describe "#decode_token_from_json" do
    let(:respone) { }
  end

  describe "#authenticate!", :vcr do
    let(:params) { {'username' => 'you@example.com', 'password' => 'mypassword'} }

    context "with valid parameters" do
      it "authenticates successfully" do
        expect(strategy.authenticate!).to eq(:success)
      end
    end

    context "with invalid password" do
      let(:params) { {'username' => 'you@example.com', 'password' => 'pass'} }

      it "fails authentication" do
        expect(strategy.authenticate!).to eq(:failure)
      end
    end

    context "with invalid username" do
      let(:params) { {'username' => 'me@example.com', 'password' => 'pass'} }

      it "fails authentication" do
        expect(strategy.authenticate!).to eq(:failure)
      end
    end

    context "with audience check" do
      let(:verify_audience) { true }

      context "and valid audience" do
        it "authenticates successfully" do
          expect(strategy.authenticate!).to eq(:success)
        end
      end

      context "and invalid audience" do
        let(:audience) { 'weiufhwef'}

        it "fails authentication" do
          expect(strategy.authenticate!).to eq(:failure)
        end
      end
    end

    context "#fetch_token" do
      context "with client_options set" do
        let(:client_options) { { :moo => :cow } }

        it "merges options into RestClient params" do
          request = double('request', :execute => nil)
          allow(RestClient::Request).to receive(:new).and_return(request)
          strategy.fetch_token
          expect(RestClient::Request).to have_received(:new).with(hash_including(client_options))
        end
      end
    end

    context "with issuer check" do
      let(:verify_issuer) { true }

      context "and valid issuer" do
        it "authenticates successfully" do
          expect(strategy.authenticate!).to eq(:success)
        end
      end

      context "and invalid issuer" do
        let(:issuer) { 'http://localhost:2000/' }

        it "raises invalid issuer exception" do
          expect{ strategy.authenticate! }.to raise_error(JWT::InvalidIssuerError)
        end
      end
    end
  end
end
