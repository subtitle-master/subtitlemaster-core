{Expectation} = require("barriertest")
util          = libRequire("util.coffee")

module.exports = (chai, utils) ->
  Expectation.addProperty 'streamChunks', ->
    stream = utils.flag(this, 'object')

    utils.flag(this, 'object', util.promisedPipe(stream, util.writeObjectsStream()))
