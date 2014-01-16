Path = require("path")

_ = require("lodash")
W = require("when")

cascade = require("../cascade_process")
scan    = require("../path_scanner")
Video   = require("../video_info")

Filters =
  video_extension: ({value, info}) ->
    extname = Path.extname(value).slice(1)
    _.include(Video.extensions, extname)

factoryFilter = (filter) -> if _.isFunction(filter) then filter else Filters[filter]

module.exports = (paths, options = {}) ->
  options = _.defaults options,
    driver: scan
    filters: ["video_extension"]

  scanFilters = _.map options.filters, (name) -> factoryFilter(name)
  scans = []

  W.promise (resolve, reject, notify) ->
    options.driver(paths).then(
      -> W.settle(scans).then -> resolve(null)
      undefined
      (path) -> scans.push(cascade(path, scanFilters).then (res) -> notify(res) if res)
    )
