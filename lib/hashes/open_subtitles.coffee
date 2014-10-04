_      = require("lodash")
W      = require("when")
nodefn = require("when/node/function")
fs     = require("fs")
Long   = require("long")

CHUNK_SIZE = 64 * 1024

module.exports =
  fromPath: _.memoize (path) ->
    nodefn.call(fs.stat, path).then (stat) ->
      fileSize = stat.size

      nodefn.call(fs.open, path, "r").then (fd) ->
        reads = _.map [0, fileSize - CHUNK_SIZE], (offset) ->
          buffer = new Buffer(CHUNK_SIZE)
          nodefn.call(fs.read, fd, buffer, 0, CHUNK_SIZE, offset).then ->
            sum = new Long(0, 0, true)
            i = 0

            while i < buffer.length
              low = buffer.readUInt32LE(i)
              high = buffer.readUInt32LE(i + 4)

              sum = sum.add(new Long(low, high))
              i += 8

            sum

        W.all(reads).then ([head, tail]) ->
          sum = head.add(tail).add(new Long(fileSize))
          [sum.toString(16), fileSize]
