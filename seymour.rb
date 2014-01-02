# seymour.rb
require 'sinatra'
require 'sinatra/json'
require 'multi_json'
require 'redis'

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

# get '/v1/' do
#   redis = Redis.new

#   feed_keys = redis.keys(params[:type] ? "#{params[:type]}:*" : '*')
#   feeds = feed_keys.map do |key|

#     if redis.type(key) != 'hash'
#       # ignore keys with non-hash values
#     else
#       feed = redis.hgetall(key)
#       # the public interface doesn't need "shelby_" as the prefix on the names of the keys
#       feed.keys.each do |k|
#         if k.start_with?('shelby_')
#           feed[k[7..-1]] = feed.delete(k)
#         end
#       end
#       feed["id"] = key
#       feed
#     end

#   end
#   feeds.compact!

#   json feeds
# end

post '/v1/' do
  redis = Redis.new

  @action = params[:action]
  @data = @params[:data]

  if @action and @data
    key = "v#{@data['video_id']}:f#{@data['frame_id']}:#{@action}"
    if redis.exists id
      # return an error if the key already exists
      422
    else
      # otherwise, save the feed info and return
      redis.mapped_hmset id, {'shelby_auth_token' => params[:auth_token], 'shelby_roll_id' => params[:roll_id]}
      json({'id' => id, 'auth_token' => params[:auth_token], 'roll_id' => params[:roll_id]})
    end
  else
    422
  end
end
