_      = require("lodash")
W      = require("when")
unfold = require("when/unfold")

sourceList = require("./sources")

module.exports = MultiSource =
  find: (path, languages) ->
    result = null

    unfold(
      (seed) -> [seed.shift(), seed]
      (seed) -> result or seed.length == 0
      (source) -> source.find(path, languages).then (res) -> result = res
      @sources()
    ).then -> result

  upload: (path, subtitlePath, cache) ->
    @uploadCacheKey(path, subtitlePath).then (cacheKey) =>
      cache.check(cacheKey).then (isCached) =>
        return "cached" if isCached

        uploads = _.map @sources(), (source) -> source.upload(path, subtitlePath)
        W.all(uploads).then -> cache.put(cacheKey); "uploaded"

  sources: -> _.map @sourceList(), (klass) -> new klass
  sourceList: sourceList
  uploadCacheKey: (path, subtitlePath) -> return W [path, subtitlePath].join("")
