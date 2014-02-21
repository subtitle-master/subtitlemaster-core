_            = require('lodash')
W            = require('when')
temp         = require("temp")
util         = require("../util")
SearchEngine = require("../search_engine")

module.exports = class AlternativeSearch
  constructor: (@path, @languages) ->
    @engine = new SearchEngine()

  run: -> @engine.search(@path, @languages).then(@downloadSubtitles)

  downloadSubtitles: (@subtitles) => util.allFulfilled(@subtitles.map(@download))

  download: (subtitle) =>
    source = subtitle.contentStream()
    target = @_writeStream()
    path   = target.path

    @_pipe(source, target).then => {path, subtitle}

  _pipe: util.promisedPipe
  _writeStream: -> temp.createWriteStream(suffix: '.srt')
