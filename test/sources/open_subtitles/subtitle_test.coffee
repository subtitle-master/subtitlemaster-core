W = require("when")
fs = require("fs")

Subtitle = libRequire("sources/open_subtitles/subtitle.coffee")

readStream = (stream) ->
  W.promise (resolve) ->
    buf = ""
    stream.on "data", (chunk) -> buf += chunk.toString()
    stream.on "end", -> resolve(buf)

describe "OpenSubtitles Subtitle", ->
  TEST_SUB_URL = "http://dl.opensubtitles.org/en/download/filead/1118.gz"

  it "downloads the file and extract it from gzip", timeout: 5000, remote: true, ->
    sub = new Subtitle(SubDownloadLink: TEST_SUB_URL)
    expected = fs.readFileSync(fixture "os_fixture.srt")

    readStream(sub.contentStream()).then (content) ->
      expect(content.length).eq expected.length
      expect(content).string(expected)

  it "correctly extracts the language", ->
    sub = new Subtitle(SubLanguageID: "eng")

    expect(sub.language()).eq "en"

  describe "#searchScore", ->
    lazy "sub", -> new Subtitle("data")

    beforeEach (sub) ->
      sub.callCount = 0
      sub.ScoreClass = class
        constructor: (@info) ->
          sub.callCount += 1
        score: -> @info

    it "sends current data to the search score and return it", (sub) ->
      expect(sub.searchScore()).eq "data"

    it "caches the score", (sub) ->
      sub.searchScore()
      sub.searchScore()

      expect(sub.callCount).eq 1
