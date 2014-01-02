# seymour.rb
require 'sinatra'
require 'sinatra/json'
require "sinatra/namespace"
require "sinatra/reloader" if development?
require 'multi_json'
require 'redis'

require "./lib/video_helper.rb"


$redis = Redis.new

configure :development, :test do
  set :bind, '0.0.0.0'
end

get '/' do
  if settings.development?
    'feed me seymour'
  else
    not_found
  end
end

namespace '/v1' do
  get '/actions' do
    json({'status' => 'OK', 'actions' => WHITELISTED_ACTIONS})
  end

  # GET all the FRAMEs connected to a VIDEO
  # [ creating this route as an example of what can be done]
  get '/video/:video_id/frames' do
    frames = Seymour::VideoHelper.get_frames_including_video(params[:video_id])
    json({'status' => "OK", 'frames' => frames})
  end

  # GET all the USERs for each step of the whitelisted funnel for a VIDEO
  # [ creating this route as an example of what can be done]
  get '/video/:video_id' do
    funnel = Seymour::VideoHelper.get_funnel_for_a_video(params[:video_id])
    frames = Seymour::VideoHelper.get_frames_including_video(params[:video_id])
    json({'status' => "OK", 'video_id' => params[:video_id], 'actions' => funnel, 'frames' => frames})
  end

  # GET all the USERs who performed an action on a VIDEO
  # [ can * is a valid action type, would return all users who "interacted" somehow with video ]
  # [ in the future this can incude multiple actions perhaps]
  get '/video/:video_id/:action' do
    begin
      users = Seymour::VideoHelper.get_users_from_video_action(params[:video_id], params[:action])
      json({'status' => "OK", 'users' => users})
    rescue => e
      json({'status' => "ERROR", 'message' => e})
    end

  end

  # POST to create an action for a video, frame, on behalf of a user
  post '/video/:video_id/:action' do
    begin
      video_action = Seymour::VideoHelper.add_user_to_video_action(params)
      json({'status' => 'OK', 'key' => video_action[:key], 'user_id' => video_action[:user_id]})
    rescue => e
      json({'status' => 'ERROR', 'msg' => e})
    end
  end

end
