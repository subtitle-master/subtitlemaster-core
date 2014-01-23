W = require("when")
_ = require("lodash")

SearchEngine = libRequire("search_engine.coffee")

factorySubtitle = (contents) -> contents: -> W(contents)

factorySource = (pattern, contents) ->
  find: (path, languages) =>
    if path.match(pattern)
      W factorySubtitle(contents)
    else
      W null

describe "Search Engine", ->
  describe "searching for a single result", ->
    lazy "engine", -> new SearchEngine([
      factorySource(/dog/, "auuu")
      factorySource(/cat/, "miii")
    ])

    it "lookup for the first subtitle available", (engine, invoke) ->
      expect(engine.find("dog", ["en"]).then(invoke "contents")).eq("auuu")

    it "fallback into subsequent sources", (engine, invoke) ->
      expect(engine.find("cat", ["en"]).then(invoke "contents")).eq("miii")

    it "returns null when nothing is found", (engine) ->
      expect(engine.find("kitty", ["en"])).null

  describe "uploading subtitle", ->
    cache = null
    lazy "engine", -> _.tap new SearchEngine(), (engine) ->
      engine.uploadCacheKey = quickStub("x", "y", W "z")

    describe "upload cached", ->
      beforeEach -> cache = check: quickStub("z", W true)

      it "returns cached", (engine) -> expect(engine.upload("x", "y", cache)).eql("cached")

    describe "upload uncached", ->
      beforeEach (sinon) -> cache =
        check: quickStub("z", W false)
        put: sinon.spy()

      it "fails if an engine fails", (engine) ->
        engine.sources = [
          upload: quickStub("x", "y", W.reject "upload error")
        ]

        expect(engine.upload("x", "y", cache)).hold.reject("upload error")

      it "returns uploaded when subtitles get uploaded and cache result", (engine) ->
        engine.sources = [
          upload: quickStub("x", "y", W success: true)
        ]

        engine.upload("x", "y", cache).then (result) ->
          expect(result).eql "uploaded"
          expect(cache.put.args).eql [["z"]]

  describe "generating cache key", ->
    it "concatenates the results of hashing each part", ->
      engine = new SearchEngine()

      expect(engine.uploadCacheKey("x", "y")).eql "xy"
