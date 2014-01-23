W       = require("when")
nodefn  = require("when/node/function")
request = require("request")

{hashToUrlParams} = require("../../util.coffee")

UA = "SubDB/1.0 (Subtitle Master/2.0.0b; http://subtitlemaster.com)"

module.exports = class SubDBAPI
  constructor: (@endpoint = "http://api.thesubdb.com/") ->

  search: (hash) -> @get("search", hash: hash).then ([r, body]) -> body.split(",")

  download: (hash, lang) -> request(@query("download", hash: hash, language: lang))

  upload: (hash, stream) ->
    @post "upload", (form) ->
      form.append("hash", hash)
      form.append("file", stream, contentType: "application/octet-stream")

  get: (action, params) -> nodefn.call(request, @query(action, params))

  post: (action, formBuilder) ->
    W.promise (resolve, reject) =>
      post = request.post @query("upload"), (err, response, body) =>
        return reject(err) if err

        resolve(response)

      formBuilder(post.form())

  query: (action, params) ->
    paramsString = hashToUrlParams(params)

    uri: "#{@endpoint}?action=#{action}&#{paramsString}"
    headers:
      "User-Agent": UA
