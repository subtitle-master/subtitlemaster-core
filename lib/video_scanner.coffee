_      = require("lodash")
nodefn = require("when/node/function")
dir    = require("node-dir")

class ScanResult
  constructor: (@path, basePath) ->
    @info = basePath: basePath

  toString: -> @path

module.exports = class VideoScanner
  constructor: ->
    @filters = []

  lookup: (path) ->
    nodefn.call(dir.files, path).then @lookupFilter(path)

  lookupFilter: (path) -> (files) =>
    _.transform files, (results, file) =>
      res = new ScanResult(file, path)
      results.push(res) if @filter(res)

  filter: (res) -> _.all @filters, (filter) -> filter.check(res)
