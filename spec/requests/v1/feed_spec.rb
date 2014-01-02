require 'spec_helper.rb'

describe 'Feeds', :redis => true do

  context "GET" do

    it "should respond with success" do
        get '/v1/feeds'
        last_response.should be_ok
        last_response.body.should have_json_path('')
        last_response.body.should have_json_type(Array).at_path('')
        last_response.body.should have_json_size(0).at_path('')
    end

    context "when there are some keys" do

      before(:each) do
        redis = Redis.new
        redis.mapped_hmset 'youtube:james', {'shelby_auth_token' => '123', 'shelby_roll_id' => '456'}
        redis.mapped_hmset 'vimeo:josh', {'shelby_auth_token' => '789', 'shelby_roll_id' => 'abc'}
      end

      it "should return feed info for all feed types" do
        get '/v1/feeds'
        last_response.should be_ok
        last_response.body.should have_json_path('')
        last_response.body.should have_json_type(Array).at_path('')
        last_response.body.should have_json_size(2).at_path('')
        last_response.body.should include_json({'id' => 'youtube:james', 'auth_token' => '123', 'roll_id' => '456'}.to_json).at_path('').including('id')
        last_response.body.should include_json({'id' => 'vimeo:josh', 'auth_token' => '789', 'roll_id' => 'abc'}.to_json).at_path('').including('id')
      end

      it "should return feed info for only the feed type specified in the type param" do
        get '/v1/feeds?type=youtube'
        last_response.should be_ok
        last_response.body.should have_json_path('')
        last_response.body.should have_json_type(Array).at_path('')
        last_response.body.should have_json_size(1).at_path('')
      end

      it "should ignore non-hash keys" do
        redis = Redis.new
        redis.set 'youtube:fred', 'string_value'

        get '/v1/feeds'
        last_response.should be_ok
        last_response.body.should have_json_path('')
        last_response.body.should have_json_type(Array).at_path('')
        last_response.body.should have_json_size(2).at_path('')
      end

    end

  end

  context "POST" do

    it "should return success if all correct arguments are supplied" do
      post '/v1/feeds?type=youtube&id=james&auth_token=123&roll_id=456'
      last_response.should be_ok
    end

    it "should return the new feed" do
      post '/v1/feeds?type=youtube&id=james&auth_token=123&roll_id=456'
      last_response.should be_ok

      last_response.body.should be_json_eql({'id' => 'youtube:james', 'auth_token' => '123', 'roll_id' => '456'}.to_json).including('id')
    end

    it "should save the new feed" do
      post '/v1/feeds?type=youtube&id=james&auth_token=123&roll_id=456'
      last_response.should be_ok

      redis = Redis.new
      feed = redis.hgetall('youtube:james')
      feed["shelby_auth_token"].should eq('123')
      feed["shelby_roll_id"].should eq('456')
    end

    it "should return an error if trying to overwrite an existing feed" do
      redis = Redis.new
      redis.hmset 'youtube:james', 'shelby_auth_token', '123', 'shelby_roll_id', '456'

      post '/v1/feeds?type=youtube&id=james&auth_token=new&roll_id=new'
      last_response.status.should eq(422)
    end

    context "verify arguments" do

      it "should return error if parameters are missing" do
        post '/v1/feeds'
        last_response.status.should eq(422)

        post '/v1/feeds?type=youtube&id=james&auth_token=123&roll_id='
        last_response.status.should eq(422)

        post '/v1/feeds?type=youtube&id=james&auth_token=&roll_id=456'
        last_response.status.should eq(422)

        post '/v1/feeds?type=&id=james&auth_token=123&roll_id=456'
        last_response.status.should eq(422)

        post '/v1/feeds?type=youtube&id=&auth_token=123&roll_id=456'
        last_response.status.should eq(422)

        post '/v1/feeds?id=james&auth_token=123&roll_id=456'
        last_response.status.should eq(422)

        post '/v1/feeds?type=youtube&id=james&roll_id=456'
        last_response.status.should eq(422)

        post '/v1/feeds?type=youtube&id=james&auth_token=123'
        last_response.status.should eq(422)

        post '/v1/feeds?type=youtube&auth_token=123&auth_token=123'
        last_response.status.should eq(422)
      end

    end

  end

end