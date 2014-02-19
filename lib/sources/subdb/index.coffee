_  = require("lodash")
fs = require("fs")

SubDBAPI = require("./api.coffee")
Subtitle = require("./subtitle.coffee")

md5Edges = require("../../hashes/md5_edges.coffee")

module.exports = class SubDB
  id: -> "subdb"
  name: -> "SubDB"
  website: -> "http://thesubdb.com"

  constructor: (@api = new SubDBAPI()) ->

  search: (path, askedLanguages) ->
    languages = askedLanguages.map (lang) -> if lang == "pb" then "pt" else lang

    @hash.fromPath(path).then (hash) =>
      @api.search(hash).then (foundLanguages) =>
        _.tap [], (subtitles) =>
          for {language, count} in foundLanguages
            continue unless _.include(languages, language)

            for version in [0...count]
              subtitles.push(new Subtitle(@sublanguage(language, askedLanguages), hash, version, this))

  upload: (path, subtitlePath) ->
    @hash.fromPath(path).then (hash) =>
      @api.upload(hash, @streamFromPath(subtitlePath))
        .then ({statusCode}) ->
          codeMap =
            "201":
              status: "uploaded"
            "403":
              status: "duplicated"
            "400":
              status: "failed"
              reason: "malformed"
            "415":
              status: "failed"
              reason: "invalid"

          _.defaults codeMap[statusCode.toString()], httpCode: statusCode

  hash: md5Edges

  streamFromPath: (path) -> fs.createReadStream(path)

  sublanguage: (current, asked) ->
    return "pb" if current == "pt" and _.include(asked, "pb")
    current
