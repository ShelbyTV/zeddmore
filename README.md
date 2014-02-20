zeddmore
=======
> winston came on board later on, but he still had a meaningful role on the team!

a sinatra-based REST API for collecting and retrieving data around videos in Shelby.tv



### Features:
- send zeddmore data via HTTP
- data can be retrieved by day or week


##CHANGEME
### Example:
`POST /v1/video/:video_id/:interval`
add video object as data in the request
eg:
`{ video: {
    title: blah,
    count: 1234,
    video_id: 5678
    etc
  } }`
