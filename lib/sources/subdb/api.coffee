W       = require("when")
nodefn  = require("when/node/function")
request = require("request")

PromisesWorker = require("../../promises_worker.coffee")
{hashToUrlParams} = require("../../util.coffee")

UA = "SubDB/1.0 (Subtitle Master/2.0.0b; http://subtitlemaster.com)"

module.exports = class SubDBAPI
  constructor: (@endpoint = "http://api.thesubdb.com/") ->
    @worker = new PromisesWorker(5, timeout: 15000)

  search: (hash) -> @get("search", hash: hash, versions: "").then ([r, body]) ->
    body.split(",").map (v) ->
      [language, count] = v.split(':')
      {language, count: parseInt(count)}

  download: (hash, language, version) -> request(@query("download", {hash, language, version}))

  upload: (hash, stream) ->
    @post "upload", (form) ->
      form.append("hash", hash)
      form.append("file", stream, contentType: "application/octet-stream")

  get: (action, params) -> @worker.push(run: => nodefn.call(request, @query(action, params)))

  post: (action, formBuilder) ->
    @worker.push
      run: => W.promise (resolve, reject) =>
        post = request.post @query("upload"), (err, response, body) =>
          return reject(err) if err

          resolve(response)

        formBuilder(post.form())

  query: (action, params) ->
    paramsString = hashToUrlParams(params)

    uri: "#{@endpoint}?action=#{action}&#{paramsString}"
    headers:
      "User-Agent": UA
