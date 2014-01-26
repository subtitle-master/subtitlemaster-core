_       = require("lodash")
request = require("request")
zlib    = require("zlib")

OpenSubtitlesScore = require("./score.coffee")
LANG               = require("../../languages.coffee")

module.exports = class OpenSubtitlesSubtitle
  constructor: (@info, @source) ->

  contentStream: -> request.get(@info.SubDownloadLink).pipe(zlib.createGunzip())

  language: -> _.find(LANG, iso639_2b: @info.SubLanguageID).iso639_1

  searchScore: -> @score ?= new @ScoreClass(@info).score()

  ScoreClass: OpenSubtitlesScore
