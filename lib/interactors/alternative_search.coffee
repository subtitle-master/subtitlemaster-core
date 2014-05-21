_              = require('lodash')
W              = require('when')
temp           = require("temp")
util           = require("../util")
SearchEngine   = require("../search_engine")
{SubtitleInfo} = require("../local_subtitle_info.coffee")

module.exports = class AlternativeSearch
  constructor: (@path, @languages) ->
    @engine = new SearchEngine()

  run: -> @engine.search(@path, @languages).then(@downloadSubtitles)

  downloadSubtitles: (@subtitles) => util.allFulfilled(@subtitles.map(@download))

  download: (subtitle) =>
    source = subtitle.contentStream()
    target = @_writeStream()
    path   = target.path
    sourcePath = @path
    targetPath = @_subtitlePath(subtitle)

    @_pipe(source, target).then => {path, subtitle, sourcePath, targetPath}

  _subtitlePath: (subtitle) =>
    language = subtitle.language()

    (new SubtitleInfo(@path)).pathForLanguage(language)

  _pipe: util.promisedPipe
  _writeStream: -> temp.createWriteStream(suffix: '.srt')
