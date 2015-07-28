require 'addressable/uri'
require 'ostruct'
require 'jwt'
require 'warden'
require 'rest_client'

module Warden
  module JWT
    class Strategy < ::Warden::Strategies::Base

      def valid?
        !!params[config[:username_param]] && !!params[config[:password_param]]
      end

      def authenticate!
        token = fetch_token do |json|
          decode_token_from_json(json)
        end

        if token
          success!(token)
        else
          fail!("Could not log in")
        end
      end

      def config
        @config ||= ::Warden::JWT::Config.new(env, scope).to_hash
      end

      def fetch_token
        token_url = Addressable::URI.parse(config[:issuer])
        token_url.path = "/oauth/token"

        response = ::RestClient.post(
          token_url.to_s,
          {
            :grant_type => :password,
            :username => params[config[:username_param]],
            :password => params[config[:password_param]]
          }
        )

        yield(response) if block_given?
      rescue RestClient::Unauthorized
        false
      end

      def decode_token_from_json(response)
        json_token = JSON.parse(response)["access_token"]

        token = ::JWT.decode(
          json_token,
          config[:secret],
          true,
          {
            'iss' => config[:issuer],
            :verify_iss => config[:verify_issuer],
            'aud' => config[:audience],
            :verify_aud => config[:verify_audience]
          }
        ).first

        OpenStruct.new(token)
      rescue ::JWT::InvalidAudError
        # this simply means our app isn't authorised for this user, no biggie
        false
      end
    end
  end
end

Warden::Strategies.add(:jwt, Warden::JWT::Strategy)
