require 'spec_helper'

describe Warden::JWT::Config do
  let(:warden_scope) { :test_scope }

  let(:env) do
    { 'warden' => double(:config => warden_config) }
  end

  let(:warden_config) do
    { :scope_defaults => { warden_scope => { :config => scope_config } } }
  end

  let(:scope_config) do
    {}
  end

  let(:request) do
    double(:url => 'http://example.com/the/path', :path => '/the/path')
  end

  subject(:config) do
    described_class.new(env, warden_scope)
  end

  before do
    allow(config).to receive_messages(:request => request)
  end

  def silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end

  describe '#audience' do
    context 'when specified in scope config' do
      it 'returns the audience' do
        scope_config[:audience] = 'foobar'
        expect(config.audience).to eq 'foobar'
      end
    end

    context 'when specified in ENV' do
      it 'returns the audience' do
        allow(ENV).to receive(:[]).with('IDENTITY_CLIENT_ID').and_return('foobar')
        expect(config.audience).to eq 'foobar'
      end
    end

    context 'when not specified' do
      it 'raises BadConfig' do
        expect { config.audience }.to raise_error(described_class::BadConfig)
      end
    end
  end

  describe '#secret' do
    context 'when specified in scope config' do
      it 'returns the client secret' do
        scope_config[:secret] = 'foobar'
        expect(config.secret).to eq 'foobar'
      end
    end

    context 'when specified in ENV' do
      it 'returns the secret' do
        allow(ENV).to receive(:[]).with('IDENTITY_SECRET').and_return('foobar')
        silence_warnings do
          expect(config.secret).to eq 'foobar'
        end
      end
    end

    context 'when not specified' do
      it 'raises BadConfig' do
        expect { config.secret }.to raise_error(described_class::BadConfig)
      end
    end
  end

  describe '#issuer' do
    context 'when specified in scope config' do
      it 'returns the identity uri' do
        scope_config[:issuer] = 'http://example.com/callback'
        expect(config.issuer).to eq 'http://example.com/callback'
      end
    end

    context 'when specified in ENV' do
      it 'returns the identity_uri' do
        allow(ENV).to receive(:[]).with('IDENTITY_URL').and_return('http://example.com/callback')
        silence_warnings do
          expect(config.issuer).to eq 'http://example.com/callback'
        end
      end
    end

    context 'when not specified' do
      it 'raises BadConfig' do
        expect { config.issuer }.to raise_error(described_class::BadConfig)
      end
    end
  end

  describe '#username_param' do
    context 'when specified in config' do
      it 'returns the username param' do
        scope_config[:username_param] = 'user'
        expect(config.username_param).to eq 'user'
      end
    end

    context 'when not specified' do
      it 'returns username' do
        expect(config.username_param).to eq 'username'
      end
    end
  end

  describe '#password_param' do
    context 'when specified in config' do
      it 'returns the password param' do
        scope_config[:password_param] = 'pass'
        expect(config.password_param).to eq 'pass'
      end
    end

    context 'when not specified' do
      it 'returns password' do
        expect(config.password_param).to eq 'password'
      end
    end
  end

  describe "#verify_issuer" do
    context 'when specified in config' do
      it 'returns the verify_issuer param' do
        scope_config[:verify_issuer] = false
        expect(config.verify_issuer).to eq false
      end
    end

    context 'when not specified' do
      it 'returns true' do
        expect(config.verify_issuer).to eq true
      end
    end
  end

  describe "#verify_audience" do
    context 'when specified in config' do
      it 'returns the verify_audience param' do
        scope_config[:verify_audience] = false
        expect(config.verify_audience).to eq false
      end
    end

    context 'when not specified' do
      it 'returns true' do
        expect(config.verify_audience).to eq true
      end
    end
  end

  describe '#to_hash' do
    it 'includes all configs' do
      scope_config.merge!(
        :issuer  => '/foo',
        :audience     => 'abc',
        :secret => '123',
        :username_param => 'wef',
        :password_param => 'wef',
        :verify_issuer => 'wef',
        :verify_audience => 'wef'
      )

      expect(config.to_hash.keys).
        to match_array([:issuer, :audience, :secret, :username_param, :password_param, :verify_issuer, :verify_audience])
      end
  end
end
