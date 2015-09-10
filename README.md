# Warden::JWT

[![Build Status](https://travis-ci.org/dgvz/warden-jwt.svg?branch=master)](https://travis-ci.org/dgvz/warden-jwt) [![Code Climate](https://codeclimate.com/github/dgvz/warden-jwt/badges/gpa.svg)](https://codeclimate.com/github/dgvz/warden-jwt) [![Test Coverage](https://codeclimate.com/github/dgvz/warden-jwt/badges/coverage.svg)](https://codeclimate.com/github/dgvz/warden-jwt/coverage)

This is a simple wrapper for [JWT](https://github.com/jwt/ruby-jwt) so that it can be used from a warden project. It provides a helper for storing the user into the session.

Warden provides a consistent interface for projects, engines, and arbitrary rack applicaitons.  The benefit of warden, is that you do not need to know what the host application considers authentication to use it.  It also provides a way to store the user in the session etc.

By using Warden::JWT, you can make use of JWT authentication mechanism in your host application, and any rack middleware or applications can just continue using warden without change.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'warden-jwt'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install warden-jwt

## Usage (Padrino)

Initialise the strategy, perhaps through `lib/warden_initializer.rb`

```ruby
require 'warden/jwt'
require 'openssl/ssl'

Warden::Strategies.add(:jwt, Warden::JWT::Strategy) do

  # over-ride success! to turn the JWT-response into a user that our app
  # can understand, then call super
  def success!(identity, message=nil)
    user = Identity.find_or_create(:email => identity.email) do |u|
      u.username = identity.email
      u.name = identity.n
      u.plain_password = 'oauthuser'
      u.role = identity.r || 'default'
    end

    super(user, message)
  end
end
```

You will also need to configure JWT for use. It's essential to define your
shared secret here, which is passed in using `:secret`.

```ruby
module WardenInitializer
  def self.registered(app)
    app.register Padrino::Warden

    app.set :default_strategies, [:jwt]
    app.set :warden_default_scope, :default

    app.set :warden_config do |config|
      config.scope_defaults(
        :default,
        :strategies => [:jwt],
        :config => {
          # :client_options => { :verify_ssl => OpenSSL::SSL::VERIFY_NONE }
          :secret => ENV['IDENTITY_JWT_SECRET']
        }
      )
      config.serialize_into_session { |user| Identity.into_session(user) }
      config.serialize_from_session { |session| Identity.from_session(session) }
    end
  end
end
```

You can pass parameters directly to RestClient using `:client_options`. The example above
disables SSL verification, which can be useful during development.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dgvz/warden-jwt. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.
