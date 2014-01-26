_ = require("lodash")

module.exports = class OpenSubtitlesScore
  constructor: (@info) ->

  score: (path) ->
    queryLanguages = @info.QueryParameters.sublanguageid.split(",").reverse()
    currentLanguage = @info.SubLanguageID

    (queryLanguages.indexOf(currentLanguage) + 1) * 10000
