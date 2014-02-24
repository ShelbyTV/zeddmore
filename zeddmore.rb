# zeddmore.rb
require 'sinatra'
require 'sinatra/json'
require "sinatra/namespace"
require "sinatra/reloader" if development?
require 'multi_json'
require 'redis'
require 'active_support/core_ext'

require "./lib/video_helper.rb"


$redis = Redis.new
WHITELISTED_ROUTES = ['GET /videos/:video_id/:interval', 'POST /video/:video_id/:interval']

configure :development, :test do
  set :bind, '0.0.0.0'
end

get '/' do
  if settings.development?
    'tell him about the twinkie'
  else
    not_found
  end
end

namespace '/v1' do
  get '/' do
    json({'status' => 'OK', 'routes' => WHITELISTED_ROUTES})
  end

  # GET all the VIDEOs for a given date and interval
  get '/videos/:date/:interval' do
    opts = {}
    opts[:sort_by] = params[:sort_by] if params[:sort_by]
    videos = Zeddmore::VideoHelper.get_set_of_videos(params[:date], params[:interval], opts)
    json({'status' => "OK", 'videos' => videos})
  end


  # POST to create an action for a video, frame, on behalf of a user
  post '/video/:video_id/:interval' do
    begin
      video = Zeddmore::VideoHelper.add_video_to_set(params[:video_id], params[:interval], params[:video])
      json({'status' => 'OK', 'key' => video[:key], 'video' => video[:video]})
    rescue => e
      json({'status' => 'ERROR', 'msg' => e})
    end
  end

end
