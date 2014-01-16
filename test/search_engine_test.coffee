W = require("when")

engine = libRequire("search_engine.coffee")

factorySubtitle = (contents) -> contents: -> W(contents)

factorySource = (pattern, contents) ->
  class FactorySource
    constructor: ->
    find: (path, languages) =>
      if path.match(pattern)
        W factorySubtitle(contents)
      else
        W null

describe "Search Engine", ->
  describe "searching for a single result", ->
    beforeEach (sinon) ->
      sinon.stub(engine, "sourceList").returns([
        factorySource(/dog/, "auuu")
        factorySource(/cat/, "miii")
      ])

    it "lookup for the first subtitle available", (invoke) ->
      expect(engine.find("dog", ["en"]).then(invoke "contents")).eq("auuu")

    it "fallback into subsequent sources", (invoke) ->
      expect(engine.find("cat", ["en"]).then(invoke "contents")).eq("miii")

    it "returns null when nothing is found", ->
      expect(engine.find("kitty", ["en"])).null

  describe "uploading subtitle", ->
    cache = null

    beforeEach (sinon) -> sinon.stub(engine, "uploadCacheKey").withArgs("x", "y").returns(W "z")

    describe "upload cached", ->
      beforeEach (sinon) ->
        cache = check: sinon.stub().withArgs("z").returns(W true)

      it "returns cached", -> expect(engine.upload("x", "y", cache)).eql("cached")

    describe "upload uncached", ->
      beforeEach (sinon) -> cache =
        check: sinon.stub().withArgs("z").returns(W false)
        put: sinon.spy()

      it "fails if an engine fails", (sinon) ->
        sinon.stub(engine, "sources").returns [
          upload: sinon.stub().withArgs("x", "y").returns(W.reject "upload error")
        ]

        expect(engine.upload("x", "y", cache)).hold.reject("upload error")

      it "returns uploaded when subtitles get uploaded and cache result", (sinon) ->
        sinon.stub(engine, "sources").returns [
          upload: sinon.stub().withArgs("x", "y").returns(W success: true)
        ]

        engine.upload("x", "y", cache).then (result) ->
          expect(result).eql "uploaded"
          expect(cache.put.args).eql [["z"]]

  describe "generating cache key", ->
    it "concatenates the results of hashing each part", (sinon) ->
      expect(engine.uploadCacheKey("x", "y")).eql "xy"
