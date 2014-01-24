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

  find: (path, languages) ->
    languages = languages.map (lang) -> if lang == "pb" then "pt" else lang

    @hash.fromPath(path).then (hash) =>
      @api.search(hash).then (foundLanguages) =>
        wanted = _.intersection(languages, foundLanguages)

        if wanted.length > 0
          new Subtitle(wanted[0], hash, this)
        else
          null

  upload: (path, subtitlePath) ->
    @hash.fromPath(path).then (hash) =>
      @api.upload(hash, @streamFromPath(subtitlePath))
        .then ({statusCode}) -> status: statusCode

  hash: md5Edges

  streamFromPath: (path) -> fs.createReadStream(path)
