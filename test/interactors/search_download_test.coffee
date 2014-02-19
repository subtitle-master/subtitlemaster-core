_   = require("lodash")
W   = require("when")
SDP = libRequire("interactors/search_download")
sinon = require("sinon")

describe "Search Download Operation", ->
  sdp  = null
  info = null

  testSeach = (notifyCalls, expectedResult, errorResult = false) ->
    barrierContext.inject (spy) ->
      success = (result) ->
        expect(spy.args).eql notifyCalls
        expect(result).eql expectedResult

      failure = undefined

      [success, failure] = [failure, success] if errorResult

      sdp.run().then(success, failure, spy)

  it "fails when the given path is invalid", (sinon) ->
    sdp = new SDP()
    sdp.localInfo = -> W.reject("err")

    testSeach([], "err", true)

  describe "given an simple valid path and languages", ->
    beforeEach ->
      sdp = new SDP("path", ["pt", "en"])

    it "resolves into unchanged when all wanted subtitles are available", (sinon) ->
      info =
        hasSubtitles: -> false
        missingFrom: quickStub(['pt', 'en'], true, [])
        pathForLanguage: quickStub('en', 'path.en.srt')

      sdp.initialViewPath = -> 'viewPath'
      sdp.localInfo = -> W info

      testSeach [
        [["info", info]]
        [["viewPath", "viewPath"]]
      ], "unchanged"

    describe "given there are files to upload", ->
      beforeEach (sinon) ->
        info =
          subtitles: ["pt"]
          hasSubtitles: -> true
          pathForLanguage: quickStub('pt', 'subpath')
          missingFrom: quickStub(['pt', 'en'], true, [])

        sdp.initialViewPath = -> 'viewPath'
        sdp.localInfo = -> W info

      it "raises error when upload raises an error", (sinon) ->
        sdp.upload = quickStub('subpath', W.reject 'upload error')

        testSeach [
          [["info", info]]
          [["viewPath", "viewPath"]]
          [["upload", "subpath"]]
        ], "upload error", true

      it "keeps unchanged status when upload returns cached", (sinon) ->
        sdp.upload = quickStub('subpath', W 'cached')

        testSeach [
          [["info", info]]
          [["viewPath", "viewPath"]]
          [["upload", "subpath"]]
        ], "unchanged"

      it "returns the uploaded status when some subtitle got uploaded", (sinon) ->
        sdp.upload = quickStub("subpath", W [status: "uploaded"])

        testSeach [
          [["info", info]]
          [["viewPath", "viewPath"]]
          [["upload", "subpath"]]
        ], "uploaded"

    describe "given that are missing subtitles", ->
      beforeEach (sinon) ->
        info =
          hasSubtitles: -> false
          missingFrom: quickStub(['pt', 'en'], true, ['pt'])
          pathForLanguage: quickStub('pt', 'dest')

        sdp.initialViewPath = -> 'viewPath'
        sdp.localInfo = -> W info

      it "resolves into notfound when no source is able to find a new subtitle", (sinon) ->
        sdp.search = quickStub(['pt'], W null)

        testSeach [
          [["info", info]]
          [["viewPath", "viewPath"]]
          [["search", ["pt"]]]
        ], "notfound"

      it "rejects when search fails", (sinon) ->
        sdp.search = quickStub(["pt"], W.reject "err")

        testSeach [
          [["info", info]]
          [["viewPath", "viewPath"]]
          [["search", ["pt"]]]
        ], "err", true

      describe "given the search returns a result", ->
        subtitle = null

        beforeEach (sinon) ->
          subtitle =
            language: -> "pt"
            source: {id: -> "id"}

          sdp.search = quickStub(["pt"], W subtitle)

        it "rejects when download fails", (sinon) ->
          sdp.download = quickStub(subtitle, "dest", W.reject "down err")

          testSeach [
            [["info", info]]
            [["viewPath", "viewPath"]]
            [["search", ["pt"]]]
            [["download", subtitle]]
          ], "down err", true

        describe "given the download was complete", ->
          it "runs the entire process and return status downloaded", (sinon) ->
            sdp.download = quickStub(subtitle, 'dest', W null)
            sdp.cacheDownload = quickStub("dest", W true)
            sdp.upload = -> W true

            testSeach [
              [["info", info]]
              [["viewPath", "viewPath"]]
              [["search", ["pt"]]]
              [["download", subtitle]]
              [["viewPath", "dest"]]
              [["share", subtitle]]
            ], "downloaded"

  describe 'initialViewPath', ->
    describe 'given there is preferred language', ->
      it 'returns the path for that language', ->
        sdp = new SDP()
        sdp.languages = ['en']
        sdp.info =
          preferred: quickStub(['en'], 'en')
          pathForLanguage: quickStub('en', 'viewPath')

        expect(sdp.initialViewPath()).eq 'viewPath'

    describe 'given there is no preferred language', ->
      it 'returns the path for the file', ->
        sdp = new SDP()
        sdp.path = 'path.mkv'
        sdp.languages = ['en']
        sdp.info =
          preferred: quickStub(['en'], null)

        expect(sdp.initialViewPath()).eq 'path.mkv'

  describe 'search', ->
    it 'records search results and return its first', ->
      sub = {}

      sdp = new SDP()
      sdp.path = 'path.mkv'
      sdp.engine =
        search: quickStub('path.mkv', ['en'], [sub])

      expect(sdp.search(['en'])).eq sub
