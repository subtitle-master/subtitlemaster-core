_ = require('lodash')

negate = (fn) -> (value) -> -fn(value)

module.exports = class SubtitleScore
  constructor: (@path, @languages) ->
    @languages.reverse()

  sort: (subtitles) => _.sortBy(subtitles, negate(@scoreLanguage))

  scoreLanguage: (subtitle) =>
    currentLanguage = subtitle.language()

    subtitle.score ||= (@languages.indexOf(currentLanguage) + 1) * 10000
