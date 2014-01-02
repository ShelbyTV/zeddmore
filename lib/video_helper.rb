module Seymour
  class Videos

    def self.add_user_to_video_action(options)
      raise ArgumentError, "Must include video_id" unless video_id = options[:video_id]
      raise ArgumentError, "Must include user_id" unless user_id = options[:user_id]
      raise ArgumentError, "Must include a valid, non-empty user_id" if user_id.empty?
      raise ArgumentError, "Must include frame_id" unless frame_id = options[:frame_id]
      raise ArgumentError, "Must include action" unless action = options[:action]
      raise ArgumentError, "Must include a valid action, see /v1/action" unless WHITELISTED_ACTIONS.include? action

      key = "v#{video_id}:f#{frame_id}:#{action}"
      if $redis.sadd key, user_id
        return {:key => key, :user_id => user_id}
      else
        return nil
      end

    end

    def self.get_users_from_video_action(video_id, action)
      @users = []
      video_id_key = "v#{video_id}:f*:#{action}"
      video_keys = $redis.keys(video_id_key)
      video_keys.map do |key|
        user_set = $redis.smembers(key)
        @users << user_set
      end

      if @users.flatten!
        return @users.uniq!
      else
        return 'nil'
      end
    end

    def self.get_frames_including_video(video_id)
      @frames = []
      key = "v#{video_id}:f*:*"
      keys = $redis.keys(key)
      keys.map do |k|
        if !k.split(':').empty?
          f = k.split(':')[1][1..-1]
          @frames << f
        end
      end

      if !@frames.empty?
        return @frames
      else
        return 'nil'
      end
    end

  end
end
