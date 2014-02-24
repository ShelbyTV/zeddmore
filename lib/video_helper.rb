module Zeddmore
  class VideoHelper

    ####
    #
    #  key is in format:
    #   "Zeddmore:#{Date.today.to_s}:#{inverval}:#{video_id}"
    #
    ####

    # ADD Video Popularity TO SET
    def self.add_video_to_set(video_id, interval, video_data)
      raise ArgumentError, "Must include key" unless video_id.is_a? String
      raise ArgumentError, "Must include an approved interval (day, week)" unless ["day", "week"].include? interval
      raise ArgumentError, "Must include key" unless video_data.is_a? Hash

      key = "Zeddmore:#{Date.today.to_s}:#{interval}:#{video_id}"
      $redis.mapped_hmset(key, video_data)
      return {:key => key, :video => video_data}
    end

    # GET A DAILY SET OF VIDEOS
    def self.get_set_of_videos(date, interval, opts={})
      raise ArgumentError, "Must include a date" unless date
      raise ArgumentError, "Must include an approved interval (day, week)" unless ["day", "week"].include? interval

      interval_key = "Zeddmore:#{date}:#{interval}:*"
      video_keys = $redis.keys(interval_key)

      videos = []
      total_popularity_count = 0
      video_keys.map do |key|
        videos << $redis.hgetall(key)
      end

      if !videos.empty?
        videos.flatten!
        videos.uniq!
        videos.each {|v| total_popularity_count += v["count"].to_i }
        videos.each do |v|
          v["count_as_ratio"] = (v['count'].to_f / total_popularity_count.to_f).round(3)
          v["trend"], v["trend_error"] = get_trend(date, interval, v["video_id"], total_popularity_count)
        end

        sort_by_attr = opts[:sort_by] ? opts[:sort_by] : 'count'
        videos = videos.sort_by! { |v| v[sort_by_attr].to_i }
        videos.reverse!

        return videos
      else
        return {'msg' => "no videos found"}
      end
    end

    def self.get_trend(date, interval, video_id, total_popularity_count)
      date_minus_one = (Date.parse(date) -1.day).to_s
      # popularity for most recent day
      y2 = $redis.hget("Zeddmore:#{date}:#{interval}:#{video_id}", "count")
      # pageviews for previous day
      y1 = $redis.hget("Zeddmore:#{date_minus_one}:#{interval}:#{video_id}", "count")
      # Simple baseline trend algorithm
      if y1 and y2
        slope = y2.to_i - y1.to_i
        trend = slope  * Math.log(1.0 + total_popularity_count)
        error = 1.0/Math.sqrt(total_popularity_count)
        return trend, error
      else
        return nil, nil
      end
    end

  end
end
