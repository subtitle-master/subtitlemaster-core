_ = require("lodash")
W = require("when")

osHash   = require("../../hashes/open_subtitles.coffee")
Subtitle = require("./subtitle.coffee")
LANG     = require("../../languages.coffee")

module.exports = class OpenSubtitles
  name: -> "Open Subtitles"
  website: -> "http://www.opensubtitles.org"

  constructor: (@api) ->

  find: (path, languages) ->
    @hashQuery(path, languages).then (query) =>
      @api.search([query]).then ({data}) =>
        return null unless data

        new Subtitle(data[0], this)

  upload: -> W null

  hash: osHash

  hashQuery: (path, languages) ->
    languages = @mapLanguages(languages).join(",")

    @hash.fromPath(path).then ([hash, byteSize]) =>
      sublanguageid: languages
      moviehash:     hash
      moviebytesize: byteSize

  mapLanguages: (languages) ->
    for lang in languages
      _.find(LANG, iso639_1: lang).iso639_2b
