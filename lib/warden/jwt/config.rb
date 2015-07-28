module Warden
  module JWT
    # This class encapsulates the configuration of the strategy. A strategy can
    # be configured through Warden::Manager by defining a scope's default. Thus,
    # it is possible to use the same strategy with different configurations by
    # using multiple scopes.
    #
    # To configure a scope, use #scope_defaults inside the Warden::Manager
    # config block. The first arg is the name of the scope (the default is
    # :default, so use that to configure the default scope), the second arg is
    # an options hash which should contain:
    #
    #   - :strategies : An array of strategies to use for this scope. Since this
    #                   strategy is called :jwt, include it in the array.
    #
    #   - :config :     A hash containing the configs that are used for JWT.
    #                   Valid parameters include :issuer, :audience, :secret,
    #                   :verify_issuer, :verify_audience,
    #                   :username_param, and :password_param.
    #
    #                   If :issuer, :audience or :secret are not specified, they
    #                   will be fetched from -
    #                     ENV['IDENTITY_URL'],
    #                     ENV['IDENTITY_CLIENT_ID'] and
    #                     ENV['IDENTITY_SECRET'], respectively.
    #
    #                   If :username_param or :password_param are not specified,
    #                   they will be fetched from -
    #                     params['username'],
    #                     params['password'], respectively.
    #
    # Examples
    #
    #   use Warden::Manager do |config|
    #     config.failure_app = BadAuthentication
    #
    #     # The following line doesn't specify any custom configurations, thus
    #     # the default scope will be using the implict client_id,
    #     # client_secret, and redirect_uri.
    #     config.default_strategies :jwt
    #
    #     # This configures an additional scope that uses the jwt strategy
    #     # with custom configuration.
    #     config.scope_defaults :admin, :config => { :issuer => 'foobar',
    #                                                :audience => 'barfoo',
    #                                                :secret => 'foobarfoo' }
    #   end
    class Config
      BadConfig = Class.new(StandardError)

      include ::Warden::Mixins::Common

      attr_reader :env, :warden_scope

      def initialize(env, warden_scope)
        @env = env
        @warden_scope = warden_scope
      end

      def issuer
        custom_config[:issuer] ||
          ENV['IDENTITY_URL'] ||
          fail(BadConfig, 'Missing issuer configuration.')
      end

      def audience
        custom_config[:audience] ||
          ENV['IDENTITY_CLIENT_ID'] ||
          fail(BadConfig, 'Missing audience configuration.')
      end

      def secret
        custom_config[:secret] ||
          ENV['IDENTITY_SECRET'] ||
          fail(BadConfig, 'Missing secret configuration.')
      end

      def username_param
        custom_config[:username_param] ||
          "username"
      end

      def password_param
        custom_config[:password_param] ||
          "password"
      end

      def verify_issuer
        custom_config.fetch(:verify_issuer, true)
      end

      def verify_audience
        custom_config.fetch(:verify_audience, true)
      end

      def to_hash
        { :issuer     => issuer,
          :audience   => audience,
          :secret     => secret,
          :username_param => username_param,
          :password_param => password_param,
          :verify_issuer => verify_issuer,
          :verify_audience => verify_audience }
      end

      private

      def custom_config
        @custom_config ||=
          env['warden'].
            config[:scope_defaults].
            fetch(warden_scope, {}).
            fetch(:config, {})
      end
    end
  end
end
