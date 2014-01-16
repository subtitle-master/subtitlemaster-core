W = require("when")

module.exports =
  promisedPipe: (input, output) ->
    defer = W.defer()
    input.pipe(output)
    input.on "end", -> defer.resolve(null)
    defer.promise

  hashToUrlParams: (params) ->
    string = []

    for key, value of params
      string.push("#{key}=#{value}")

    string.join("&")
