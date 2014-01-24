_      = require("lodash")
W      = require("when")
unfold = require("when/unfold")

module.exports = class SearchEngine
  constructor: (@sources = require("./sources")()) ->

  find: (path, languages) ->
    result = null

    unfold(
      (seed) -> [seed.shift(), seed]
      (seed) -> result or seed.length == 0
      (source) -> source.find(path, languages).then (res) -> result = res
      @sources.slice(0)
    ).then -> result

  upload: (path, subtitlePath, cache) ->
    @uploadCacheKey(path, subtitlePath).then (cacheKey) =>
      W.all _.map @sources, (source) ->
        sourceCacheKey = cacheKey + "-#{source.id()}"

        cache.check(sourceCacheKey).then (isCached) =>
          return "cached" if isCached

          source.upload(path, subtitlePath).then (result) ->
            cache.put(sourceCacheKey).then -> result

  uploadCacheKey: (path, subtitlePath) ->
    W.all([@md5Edges(path), @md5(subtitlePath)]).then (res) -> res.join("-")

  cacheDownload: (cache, path, subtitlePath, sourceId) ->
    @uploadCacheKey(path, subtitlePath).then (key) -> cache.put("#{key}-#{sourceId}")

  md5Edges: require("./hashes/md5_edges.coffee").fromPath
  md5:      require("./hashes/md5.coffee").fromPath
