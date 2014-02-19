_ = require("lodash")
W = require("when")

osHash   = require("../../hashes/open_subtitles.coffee")
Subtitle = require("./subtitle.coffee")
LANG     = require("../../languages.coffee")

module.exports = class OpenSubtitles
  id: -> "open_subtitles"
  name: -> "Open Subtitles"
  website: -> "http://www.opensubtitles.org"

  constructor: (@api) ->

  search: (path, languages) ->
    @hashQuery(path, languages).then (query) =>
      @api.search([query]).then ({data}) =>
        return [] unless data

        _.map(data, (s) => new @SubtitleClass(s, this))

  # findBest: (data, path) ->
  #   return null if data.length == 0

  #   _(data)
  #     .map((s) => new @SubtitleClass(s, this))
  #     .sortBy((s) => -s.searchScore(path))
  #     .first()

  upload: -> W status: "not-implemented"

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

  SubtitleClass: Subtitle
