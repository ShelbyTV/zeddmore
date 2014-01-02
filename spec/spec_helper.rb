require './seymour'
require 'rspec'
require 'rack/test'
require 'json_spec'
require 'rspec-redis_helper'
# Require your modules here
# this is how i do it:
# require_relative '../sinatra_modules'

def app
  Sinatra::Application # It is must and tell rspec that test it running is for sinatra
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include JsonSpec::Helpers
  config.include RSpec::RedisHelper, redis: true

  # clean the Redis database around each run
  # @see https://www.relishapp.com/rspec/rspec-core/docs/hooks/around-hooks
  config.around( :each, redis: true ) do |example|
    with_clean_redis do
      example.run
    end
  end

  # config.order = 'random'
end
