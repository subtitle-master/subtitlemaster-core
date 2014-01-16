_      = require("lodash")
W      = require("when")
nodefn = require("when/node/function")
fs     = require("fs")
crypto = require("crypto")

CHUNK_SIZE = 64 * 1024

module.exports =
  fromPath: (path) ->
    buffer = new Buffer(CHUNK_SIZE * 2)

    nodefn.call(fs.stat, path).then (stat) ->
      fileSize = stat.size

      nodefn.call(fs.open, path, "r").then (fd) ->
        reads = _.map [0, fileSize - CHUNK_SIZE], (offset, index) ->
          nodefn.call(fs.read, fd, buffer, CHUNK_SIZE * index, CHUNK_SIZE, offset)

        W.all(reads).then ->
          md5sum = crypto.createHash("md5")
          md5sum.update(buffer)
          md5sum.digest("hex")
