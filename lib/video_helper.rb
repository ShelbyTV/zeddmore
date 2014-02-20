module Zeddmore
  class VideoHelper

    ####
    #
    #  key is in format:
    #   "Zeddmore:#{Date.today.to_s}:#{inverval}:#{video_id}"
    #
    ####

    # ADD Video Popularity TO SET
    def self.add_video_to_set(video_id, interval)
      raise ArgumentError, "Must include key" unless video_id.is_a? String
      raise ArgumentError, "Must include an approved interval (day, week)" unless ["day", "week"].include? interval

      key = "Zeddmore:#{Date.today.to_s}:#{inverval}:#{video_id}"
      $redis.mapped_hmset(key, options)
      return {:key => key, :video => options}
    end

    # GET A DAILY SET OF VIDEOS
    def self.get_set_of_videos(date, interval)
      raise ArgumentError, "Must include a date" unless date
      raise ArgumentError, "Must include an approved interval (day, week)" unless ["day", "week"].include? interval

      interval_key = "#{date}:#{inverval}:*"
      video_keys = $redis.keys(interval_key)

      videos = []
      video_keys.map do |key|
        videos << $redis.hgetall(key)
      end

      if !videos.empty?
        videos.flatten!
        videos.uniq!
        return {"status" => "OK", 'videos' => videos}
      else
        return {"status" => 'error', 'msg' => "no videos found"}
      end
    end

  end
end
