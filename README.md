zeddmore
=======

a sinatra-based REST API for collecting and retrieving data around videos in Shelby.tv

### Features:
- send zeddmore data via HTTP
- data can be retrieved by day or week


##CHANGEME
### Example:
`POST /v1/video/:video_id/:action/?frame_id=:frame_id&user_id=:user_id'`
would add the following data to redis as a set:
key: `video_id:frame_id:action`
value: `[user_id]`
