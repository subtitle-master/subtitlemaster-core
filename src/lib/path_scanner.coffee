fs   = require("fs")
Path = require("path")

_      = require("lodash")
W      = require("when")
unfold = require("when/unfold")
nodefn = require("when/node/function")

process = (paths) ->
  path = paths.shift()

  nodefn.call(fs.stat, path).then (stat) ->
    return path unless stat.isDirectory()

    nodefn.call(fs.readdir, path).then (files) ->
      for file in files
        fullPath = Path.join(path, file)
        paths.push(fullPath)

      undefined
  , ->

module.exports = PathScanner = (paths) ->
  results = []

  W.promise (resolve, reject, notify) ->
    unfold(
      (seed) -> [process(seed), seed]
      (seed) -> seed.length == 0
      (path) ->
        if path
          notify(path)
          results.push(path)

      paths
    ).then -> resolve(results)
