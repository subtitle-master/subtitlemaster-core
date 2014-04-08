_    = require("lodash")
Path = require("path")

SHOW_REGEX = [
  /(.+)\sS(\d+)E(\d+)/i
  /(.+)\s(\d)(\d{2})/
]

normalize = (path) -> _.last path.replace(/\./g, " ").split(Path.sep)

module.exports = (path) ->
  path = normalize(path)

  if match = _(SHOW_REGEX).invoke("exec", path).find()
    name: match[1]
    season: parseInt(match[2])
    episode: parseInt(match[3])
  else
    null
