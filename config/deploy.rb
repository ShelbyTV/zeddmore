require "bundler/capistrano"

set :application, "zeddmore"
set :user, "gt"
set :deploy_to, "/home/gt/zeddmore"

default_run_options[:pty] = true

#############################################################
# Git
#############################################################

set :scm, :git

#keep a local cache to speed up deploys
set :deploy_via, :remote_cache
# Use developer's local ssh keys when git clone/updating on the remote server
ssh_options[:forward_agent] = true

require 'capistrano-unicorn'

role :web, "198.101.158.13"
role :app, "198.101.158.13"

set :repository,  "git@github.com:ShelbyTV/zeddmore.git"
set :branch, "master"
set :rails_env, "production"
set :unicorn_env, "production"
set :app_env,     "production"

after 'deploy:restart', 'unicorn:duplicate'
