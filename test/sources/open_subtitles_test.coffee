W  = require("when")

OpenSubtitles = libRequire("sources/open_subtitles")

describe "Open Subtitles Source", ->
  lazy "api", -> {}
  lazy "source", (api) -> new OpenSubtitles(api)

  path = "path"
  lang = ["en"]

  describe "#find", ->
    it "returns null when no subtitle is found", (source, api) ->
      source.hashQuery = quickStub(path, lang, W "query")
      api.search = quickStub(["query"], W data: null)

      expect(source.find(path, lang)).null

    it "returns an item from the result as a subtitle instance", (source, api) ->
      source.hashQuery = quickStub(path, lang, W "query")
      source.findBest = quickStub(data = [{}], path, sub = {})

      api.search = quickStub(["query"], W data: data)

      source.find(path, lang).then (subtitle) ->
        expect(subtitle).eq sub

  describe "#hashQuery", ->
    lang = ["en", "pt"]

    it "returns a query struct with for a given path and language", (source) ->
      source.hash = fromPath: quickStub(path, W ["hash", 123])

      expect(source.hashQuery(path, lang)).eql
        sublanguageid: "eng,por"
        moviehash: "hash"
        moviebytesize: 123

  describe "#findBest", ->
    beforeEach (source) ->
      source.SubtitleClass = class SimpleRankSubtitle
        constructor: (@score, @source) ->
        searchScore: (@path) -> @score

    it "returns null when a blank list is given", (source) ->
      expect(source.findBest([])).eql null

    it "instantiate the subtitle class and return the one with the best score", (source) ->
      best = source.findBest([1, 3, 2], "path")

      expect(best.score).eq 3
      expect(best.source).eq source
      expect(best.path).eq "path"
