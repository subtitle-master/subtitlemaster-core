_      = require("lodash")
nodefn = require("when/node/function")
fs     = require("fs")
crypto = require("crypto")

module.exports =
  fromPath: _.memoize (path) ->
    nodefn.call(fs.readFile, path).then (data) ->
      md5 = crypto.createHash("md5")
      md5.update(data)
      md5.digest("hex")
