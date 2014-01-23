W      = require("when")
xmlrpc = require("xmlrpc")

module.exports = class OpenSubtitlesAPI
  constructor: (@userAgent) ->
    @client = xmlrpc.createClient(host: "api.opensubtitles.org", path: "/xml-rpc")

  auth: ->
    @LogIn().then ({status, token}) =>
      if status == "200 OK"
        @authToken = token
      else
        throw new Error("Can't login on OpenSubtitles")

  search: (query) -> @ensureAuth().then (token) => @SearchSubtitles(token, query)

  ensureAuth: ->
    if @authToken
      W @authToken
    else
      @auth()

  LogIn: -> @call("LogIn", "", "", "en", @userAgent)
  SearchSubtitles: (token, query) -> @call("SearchSubtitles", token, query)

  call: (method, args...) ->
    W.promise (resolve, reject) =>
      @client.methodCall method, args, (err, value) ->
        return reject(err) if err

        resolve(value)

# quick OpenSubtitles XMLRPC used calls reference
#
# struct LogIn(
#   string $username,
#   string $password,
#   string $language,
#   string $useragent
# )
#
# struct SearchSubtitles(
#   $token,
#   array(
#     struct(
#       "sublanguageid" => $sublanguageid,
#       "moviehash"     => $moviehash,
#       "moviebytesize" => $moviesize,
#       "imdbid"        => $imdbid,
#       "query"         => "movie name",
#       "season"        => "season number",
#       "episode"       => "episode number",
#       "tag"           => tag
#     ), struct(...)
#   ),
#   struct('limit' => 500)
# )