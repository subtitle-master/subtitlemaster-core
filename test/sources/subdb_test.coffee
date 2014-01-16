W        = require("when")
SubDB    = libRequire("sources/subdb")
Subtitle = libRequire("sources/subdb/subtitle.coffee")

describe "SubDB", ->
  INFO =
    hash: "edc1981d6459c6111fe36205b4aff6c2"

  lazy "api", -> {}
  lazy "source", (api) -> new SubDB(api)

  describe "source information", ->
    it "has the source name", (source) -> expect(source.name()).string "SubDB"
    it "has the source website", (source) -> expect(source.website()).string "http://thesubdb.com"

  describe "#find", ->
    lazy "source", (source) ->
      source.hash = fromPath: -> W INFO.hash
      source

    it "returns null if there is no subtitle in request language", (source, api) ->
      api.search = quickStub(INFO.hash, W [])

      expect(source.find("video.mp4", ["pb"])).null

    it "find subtitle", (api, source) ->
      api.search = quickStub(INFO.hash, W ["en", "es", "fr", "it", "pt"])

      source.find("video.mp4", ["en", "pb", "pt"])
        .then (subtitle) ->
          expect(subtitle).instanceof Subtitle
          expect(subtitle.language()).eq "en"
          expect(subtitle.hash).eq INFO.hash
          expect(subtitle.source).eq source

    it "currectly converts asked brazilian portuguese to pt", (api, source) ->
      api.search = quickStub(INFO.hash, W ["en", "es", "fr", "it", "pt"])

      source.find("video.mp4", ["pb"]).then (subtitle) ->
          expect(subtitle.language()).eq "pt"

  describe "#upload", ->
    it "post the information and return the status code", (api, source) ->
      source.hash = fromPath: quickStub(path = "video.mp4", W hash = "hash")
      source.streamFromPath = quickStub(subPath = "abc", stream = "stream")

      api.upload = quickStub(hash, stream, W statusCode: 201)

      expect(source.upload(path, subPath)).eql status: 201
