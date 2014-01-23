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
      cache.check(cacheKey).then (isCached) =>
        return "cached" if isCached

        uploads = _.map @sources, (source) -> source.upload(path, subtitlePath)
        W.all(uploads).then -> cache.put(cacheKey); "uploaded"

  uploadCacheKey: (path, subtitlePath) -> return W [path, subtitlePath].join("")
