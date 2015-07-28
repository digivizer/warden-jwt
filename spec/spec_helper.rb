$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'warden/jwt'
require 'webmock/rspec'
require 'support/vcr'
require 'rubygems'
require 'rack'


Dir[File.join(File.dirname(__FILE__), "helpers", "**/*.rb")].each do |f|
  require f
end

RSpec.configure do |config|
  config.include(Warden::Spec::Helpers)
end
