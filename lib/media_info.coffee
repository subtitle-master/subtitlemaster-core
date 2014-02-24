Path = require('path')

_ = require('lodash')

VideoInfo = require("./video_info.coffee")

module.exports = class MediaInfo
  MATCH_REGXP = /(.+)\sS(\d{2})E\d{2}/i

  from: (path) ->
    return null if @_isSample(path)
    return null unless @_isVideo(path)

    if matches = @_normalize(path).match(MATCH_REGXP)
      path: path
      name: matches[1]
      season: parseInt(matches[2])
    else
      null

  _normalize: (path) -> Path.basename(path.replace(/\./g, ' '))

  _isSample: (path) -> path.indexOf('sample') >= 0
  _isVideo: (path) ->
    ext = Path.extname(path).slice(1)
    _.include(VideoInfo.extensions, ext)
