_       = require("lodash")
request = require("request")
zlib    = require("zlib")

LANG = require("../../languages.coffee")

module.exports = class OpenSubtitlesSubtitle
  constructor: (@info, @source) ->

  contentStream: -> request.get(@info.SubDownloadLink).pipe(zlib.createGunzip())

  language: -> _.find(LANG, iso639_2b: @info.SubLanguageID).iso639_1
  hash: -> @info.MovieHash

  toString: -> "OpenSubtitles Subtitle #{@hash()}"
