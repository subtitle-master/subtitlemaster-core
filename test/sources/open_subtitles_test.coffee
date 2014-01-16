W  = require("when")

OpenSubtitles = libRequire("sources/open_subtitles")
Subtitle = libRequire("sources/open_subtitles/subtitle.coffee")

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
      api.search = quickStub(["query"], W data: [data = {}])

      source.find(path, lang).then (subtitle) ->
        expect(subtitle).instanceof(Subtitle)
        expect(subtitle.source).eq source
        expect(subtitle.info).eq data

  describe "#hashQuery", ->
    lang = ["en", "pt"]

    it "returns a query struct with for a given path and language", (source) ->
      source.hash = fromPath: quickStub(path, W ["hash", 123])

      expect(source.hashQuery(path, lang)).eql
        sublanguageid: "eng,por"
        moviehash: "hash"
        moviebytesize: 123
