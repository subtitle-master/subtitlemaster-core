Stream        = require("stream")
{Expectation} = require("barriertest")
util          = libRequire("util.coffee")

class ListWriteStream extends Stream.Writable
  constructor: ->
    super(objectMode: true)

    @items = []

  contents: => @items

  _write: (chunk, encoding, callback) =>
    @items.push(chunk)
    callback()

module.exports = (chai, utils) ->
  Expectation.addProperty 'streamChunks', ->
    stream = utils.flag(this, 'object')

    utils.flag(this, 'object', util.promisedPipe(stream, new ListWriteStream()))
