_      = require("lodash")
nodefn = require("when/node/function")
fs     = require("fs")
Path   = require("path")

regexpQuote = require("regexp-quote")

class SubtitleInfo
  constructor: (@path, @subtitles) ->
    @extname  = Path.extname(@path)
    @dirname  = Path.dirname(@path)
    @basename = Path.basename(@path, @extname)
    @basepath = Path.join(@dirname, @basename)

  hasSubtitles: -> @subtitles.length > 0

  pathForLanguage: (language) ->
    if language
      "#{@basepath}.#{language}.srt"
    else
      "#{@basepath}.srt"

  missingFrom: (desired, ignoreToRight = false) ->
    missing = []

    for lc in desired
      if @subtitles.indexOf(lc) > -1
        break if ignoreToRight
      else
        missing.push(lc)

    missing

subnamePattern = (filePath) ->
  ext      = Path.extname(filePath)
  basename = Path.basename(filePath, ext)
  quoted   = regexpQuote(basename)

  new RegExp("^#{quoted}(?:\\.([a-z]{2}))?\\.srt$", "i")

extractLanguages = (files, pattern) ->
  _.transform files, (languages, file) ->
    if match = file.match(pattern)
      languages.push(match[1] || null)

module.exports = (videoPath) ->
  dirname  = Path.dirname(videoPath)

  nodefn.call(fs.readdir, dirname).then (files) ->
    pattern = subnamePattern(videoPath)

    new SubtitleInfo(videoPath, extractLanguages(files, pattern))
