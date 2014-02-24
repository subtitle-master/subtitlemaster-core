{Readable, Writable} = require("stream")
fs         = require("fs")
path = require('path')

_ = require("lodash")
W = require("when")

class DirectoryReadStream extends Readable
  constructor: (@path, @maxDepth = 0) ->
    super(objectMode: true)

    @queue = [@path]
    @currentDepth = 0

  _read: =>
    if @queue.length > 0
      @_processNext()
    else
      @push(null)

  _processNext: =>
    @current = @queue.shift()

    @_stat @current, @_processStat

  _processStat: (err, stat) =>
    if stat.isDirectory()
      @_processDirectory()
    else
      @push(@current)

  _processDirectory: => @_readdir(@current, @_processFileList)

  _processFileList: (err, files) =>
    for file in files
      @queue.push(path.join(@current, file))

    @_read()

  _stat: fs.stat
  _readdir: fs.readdir

class ListWriteStream extends Writable
  constructor: ->
    super(objectMode: true)

    @items = []

  contents: => @items

  _write: (chunk, encoding, callback) =>
    @items.push(chunk)
    callback()

module.exports =
  promisedPipe: (input, output) ->
    defer = W.defer()

    input.on "error", (err) -> defer.reject(err)
    input.on "end", ->
      if (_.isFunction(output.contents))
        defer.resolve(output.contents())
      else
        defer.resolve(null)

    pipe = input.pipe(output)

    defer.promise

  hashToUrlParams: (params) ->
    string = []

    for key, value of params
      string.push("#{key}=#{value}")

    string.join("&")

  allFulfilled: (promises) ->
    W.settle(promises).then (res) ->
      _(res)
        .filter(state: 'fulfilled')
        .map('value')
        .value()

  directoryStream: (path) -> new DirectoryReadStream(path)

  writeObjectsStream: -> new ListWriteStream()
