fs = require('fs')
Path = require('path')

MediaInfo = require('../media_info.coffee')
util      = require('../util.coffee')

_      = require('lodash')
nodefn = require('when/node/function')
mkdirp = require('mkdirp')

class OrganizeMover
  constructor: (@source, @target, @newShow) ->
    @moved = false

  move: =>
    return if @moved

    nodefn.call(mkdirp, Path.dirname(@target)).then =>
      nodefn.call(fs.rename, @source, @target) =>
        @moved = true

module.exports = class OrganizeMedia
  scan: (source, target) =>
    util.promisedPipe(@scanStream(source, target), util.writeObjectsStream())

  scanStream: (@source, @target) =>
    util.directoryStream(@source)
      .pipe(util.transformStream(@_extractMediaInfoTransform))
      .pipe(util.transformStream(@_matchTargetTransform))

  matchTarget: (info) =>
    @findBestMatch(info.name).then ({name, isNew}) =>
      info.name = name

      new OrganizeMover(info.path, @_targetPath(info), isNew)

  findBestMatch: (name) =>
    @_targetShows().then (shows) =>
      currentName = _.find shows, (s) -> s.toLowerCase() == name.toLowerCase()

      if currentName
        name: currentName
        isNew: false
      else
        name: @_capitalizeWords(name)
        isNew: true

  readTargetShows: =>
    nodefn.call(fs.readdir, @target).then (files) =>
      statPromises = files.map (f) => @_statWithPath(Path.join(@target, f))

      util.allFulfilled(statPromises).then (stats) =>
        _(stats)
          .filter(({stat}) -> stat.isDirectory())
          .map('path')
          .value()

  _statWithPath: (path) =>
    nodefn.call(fs.stat, path).then (stat) => {stat, path: Path.basename(path)}

  _targetShows: => @_targetShowsCache ||= @readTargetShows()

  _targetPath: ({path, season, name}) =>
    season = if season < 10 then "0#{season}" else season.toString()

    Path.join(@target, name, "Season #{season}", Path.basename(path))

  _extractMediaInfoTransform: (stream, chunk, callback) =>
    stream.push(info) if info = new MediaInfo().from(chunk)

  _matchTargetTransform: (stream, chunk, callback) =>
    @matchTarget(chunk).then (entry) =>
      stream.push(entry)

  _capitalizeWords: (string) -> string.split(' ').map(@_capitalizeWord).join(' ')

  _capitalizeWord: (word) -> word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
