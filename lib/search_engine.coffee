_ = require("lodash")
W = require("when")

SubtitleScore = require('./subtitle_score.coffee')

module.exports = class SearchEngine
  constructor: (@sources = require("./sources")()) ->

  search: (path, languages) =>
    sort = _.partial(@sort, path, languages)
    @_searchOnSources(path, languages).then(sort)

  sort: (path, languages, subtitles) => new SubtitleScore(path, languages).sort(subtitles)

  # list of status for upload results
  #
  # uploaded
  # cached
  # duplicated
  # failed
  # not-implemented
  upload: (path, subtitlePath, cache) ->
    @uploadCacheKey(path, subtitlePath).then (cacheKey) =>
      W.all _.map @sources, (source) ->
        sourceCacheKey = cacheKey + "-#{source.id()}"

        cache.check(sourceCacheKey).then (isCached) =>
          return status: "cached" if isCached

          source.upload(path, subtitlePath).then (result) ->
            cache.put(sourceCacheKey).then -> result

  uploadCacheKey: (path, subtitlePath) ->
    W.all([@md5Edges(path), @md5(subtitlePath)]).then (res) -> res.join("-")

  cacheDownload: (cache, path, subtitlePath, sourceId) ->
    @uploadCacheKey(path, subtitlePath).then (key) -> cache.put("#{key}-#{sourceId}")

  md5Edges: require("./hashes/md5_edges.coffee").fromPath
  md5:      require("./hashes/md5.coffee").fromPath

  _searchOnSources: (path, languages) =>
    searches = _.map @sources, (source) => source.search(path, languages)

    W.settle(searches).then (results) =>
      _(results).filter(state: 'fulfilled').map('value').flatten().value()
