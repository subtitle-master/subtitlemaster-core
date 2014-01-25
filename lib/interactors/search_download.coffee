_            = require("lodash")
W            = require("when")
fs           = require("fs")
localInfo    = require("../local_subtitle_info")
SearchEngine = require("../search_engine")
util         = require("../util")

memoryCache = (->
  memory = {}

  check: (hash) -> W memory[hash]
  put: (hash) -> W memory[hash] = true
)()

module.exports = class SearchDownloadOperation
  constructor: (@path, @languages, @cache = memoryCache) ->
    @engine = new SearchEngine()

  run: -> W.promise (@resolve, @reject, @notify) => @runLocalInfo()

  runLocalInfo: -> @localInfo(@path).then(
    (@info) => @notify ["info", @info]; @runUpload()
    @reject
  )

  runUpload: ->
    if @info.hasSubtitles()
      uploads = _.map @info.subtitles, (lang) =>
        @notify ["upload", @info.pathForLanguage(lang)]
        @upload(@path, @info.pathForLanguage(lang))

      W.all(uploads).then(
        (status) =>
          @uploaded = true if _.any(_.flatten(status), status: "uploaded")
          @runSearch()
        @reject
      )
    else
      @runSearch()

  runSearch: ->
    missing = @info.missingFrom(@languages, true)

    if missing.length > 0
      @notify ["search", missing]

      @search(@path, missing)
        .then((@subtitle) => @runDownload())
        .otherwise(@reject)
    else
      @resolve(if @uploaded then "uploaded" else "unchanged")

  runDownload: ->
    if @subtitle
      @notify ["download", @subtitle]

      subtitlePath = @info.pathForLanguage(@subtitle.language())

      @download(@subtitle, subtitlePath)
        .then(=> @cacheDownload(subtitlePath))
        .then(=> @notify ["share", @subtitle])
        .then(=> @upload(@path, subtitlePath))
        .then(=> @resolve("downloaded"))
        .otherwise(@reject)
    else
      @resolve("notfound")

  cacheDownload: (subtitlePath) ->
    @engine.cacheDownload(@cache, @path, subtitlePath, @subtitle.source.id())

  localInfo: (path) -> localInfo(path)
  search: (path, missing) -> @engine.find(path, missing)
  download: (subtitle, destination) ->
    source = subtitle.contentStream()
    target = fs.createWriteStream(destination)

    util.promisedPipe(source, target)

  upload: (path, subtitlePath) -> @engine.upload(path, subtitlePath, @cache)
