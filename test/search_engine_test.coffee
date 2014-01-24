W = require("when")
_ = require("lodash")

SearchEngine = libRequire("search_engine.coffee")

factorySubtitle = (contents) -> contents: -> W(contents)

factorySource = (pattern, contents) ->
  id: -> contents

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
    lazy "engine", -> _.tap new SearchEngine([factorySource(/dog/, "au")]), (engine) ->
      engine.uploadCacheKey = quickStub("x", "y", W "z")

    describe "upload cached", ->
      beforeEach -> cache = check: quickStub("z-au", W true)

      it "returns cached", (engine) -> expect(engine.upload("x", "y", cache)).eql([status: "cached"])

    describe "upload uncached", ->
      beforeEach (sinon) -> cache =
        check: quickStub("z-sid", W false)
        put: sinon.stub().returns(W true)

      it "fails if an engine fails", (engine) ->
        engine.sources = [
          id: -> "sid"
          upload: quickStub("x", "y", W.reject "upload error")
        ]

        expect(engine.upload("x", "y", cache)).hold.reject("upload error")

      it "returns uploaded when subtitles get uploaded and cache result", (engine) ->
        engine.sources = [
          id: -> "sid"
          upload: quickStub("x", "y", W success: true)
        ]

        engine.upload("x", "y", cache).then (result) ->
          expect(result).eql [success: true]
          expect(cache.put.args).eql [["z-sid"]]

  describe "generating cache key", ->
    it "uses md5 edges for the video and md5 for the subtitle", ->
      engine = new SearchEngine()

      expect(engine.uploadCacheKey(fixture("dexter.mp4"), fixture("famous.en.srt"))).eq "ffd8d4aa68033dc03d1c8ef373b9028c-d41d8cd98f00b204e9800998ecf8427e"

  describe "#cacheDownload", ->
    it "uses the information to build the cache info and them set it", (sinon) ->
      cache = put: quickStub("key-sid", W true)

      engine = new SearchEngine([])
      engine.uploadCacheKey = quickStub(path = "path", subpath = "subpath", W "key")
      engine.cacheDownload(cache, path, subpath, sid = "sid").true
