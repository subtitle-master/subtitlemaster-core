SubDB            = require("./subdb")

OpenSubtitles    = require("./open_subtitles")
OpenSubtitlesAPI = require("./open_subtitles/api.coffee")

module.exports = -> [
  new SubDB()
  new OpenSubtitles(new OpenSubtitlesAPI("Subtitle Master v2.0.0.dev"))
]
