# zeddmore.rb
require 'sinatra'
require 'sinatra/json'
require "sinatra/namespace"
require "sinatra/reloader" if development?
require 'multi_json'
require 'redis'

require "./lib/video_helper.rb"


$redis = Redis.new
WHITELISTED_ROUTES = ['GET /videos/:interval/:date', 'POST /video/:interval/:date']

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
  get '/videos/:interval/:date' do
    videos = Zeddmore::VideoHelper.get_set_of_videos(params[:date], params[:interval])
    json({'status' => "OK", 'videos' => videos})
  end


  # POST to create an action for a video, frame, on behalf of a user
  post '/video/:interval/:date' do
    begin
      video_action = Zeddmore::VideoHelper.add_user_to_video_action(params)
      json({'status' => 'OK', 'key' => video_action[:key], 'user_id' => video_action[:user_id]})
    rescue => e
      json({'status' => 'ERROR', 'msg' => e})
    end
  end

end
