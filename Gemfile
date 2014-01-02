source 'https://rubygems.org'

gem 'sinatra', '1.4.2'
gem 'sinatra-contrib', '1.4.0'

gem 'multi_json'
gem 'redis', '3.0.4'

# Deploy with Capistrano
gem 'capistrano', '2.15.2'
gem 'rvm-capistrano'

group :development,:test do
  gem 'rspec'
  gem 'rack-test'
  gem 'rake'
  gem 'json_spec'
  gem 'rspec-redis_helper'
  gem 'thin'
  gem 'capistrano-unicorn', :require => false
end

group :production do
  gem 'unicorn', '4.6.2'
end