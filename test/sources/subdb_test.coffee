_        = require("lodash")
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

  describe "#search", ->
    lazy "source", (source) ->
      source.hash = fromPath: -> W INFO.hash
      source

    it "returns blank list if there is no subtitle in request language", (source, api) ->
      api.search = quickStub(INFO.hash, W [])

      expect(source.search("video.mp4", ["pb"])).eql []

    describe 'with results', ->
      sr = (language, count) -> {language, count}

      beforeEach (api) ->
        api.search = quickStub(INFO.hash, W [sr('en', 1), sr('es', 1), sr('fr', 1), sr('it', 1), sr('pt', 1)])

      it "search subtitle", (api, source) ->
        source.search("video.mp4", ["en", "pb", "pt"])
          .then ([subtitle]) ->
            expect(subtitle).instanceof Subtitle
            expect(subtitle.language()).eq "en"
            expect(subtitle.hash).eq INFO.hash
            expect(subtitle.source).eq source
            expect(subtitle.version).eq 0

      it "correctly converts asked brazilian portuguese to pt", (api, source) ->
        source.search("video.mp4", ["pb"]).then ([subtitle]) ->
            expect(subtitle.language()).eq "pb"

      it "return subtitle language as pt if pb wans't asked", (api, source) ->
        source.search("video.mp4", ["pt"]).then ([subtitle]) ->
            expect(subtitle.language()).eq "pt"

      it "gets multiple results", (api, source) ->
        api.search = quickStub(INFO.hash, W [sr('en', 3), sr('es', 1), sr('fr', 2), sr('it', 1), sr('pt', 2)])
        source.search("video.mp4", ['en', "pt"]).then (subtitles) ->
          expect(subtitles).length(5)

  describe "#upload", ->
    testUploadResponse = (status, response) ->
      barrierContext.inject (api, source) ->
        source.hash = fromPath: quickStub(path = "video.mp4", W hash = "hash")
        source.streamFromPath = quickStub(subPath = "abc", stream = "stream")

        api.upload = quickStub(hash, stream, W statusCode: status)

        expect(source.upload(path, subPath)).eql _.defaults(response, httpCode: status)

    it "correct responds to uplaod response", ->
      testUploadResponse(201, status: "uploaded")

    it "correct responds to duplicated response", ->
      testUploadResponse(403, status: "duplicated")

    it "correct responds to mailformed response", ->
      testUploadResponse(400, status: "failed", reason: "malformed")

    it "correct responds to invalid response", ->
      testUploadResponse(415, status: "failed", reason: "invalid")
