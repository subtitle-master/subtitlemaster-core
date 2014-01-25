_   = require("lodash")
W   = require("when")
SDP = libRequire("interactors/search_download")

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
    sinon.stub(sdp, "localInfo").returns(W.reject("err"))

    testSeach([], "err", true)

  describe "given an simple valid path and languages", ->
    beforeEach ->
      sdp = new SDP("path", ["pt", "en"])

    it "resolves into unchanged when all wanted subtitles are available", (sinon) ->
      info =
        hasSubtitles: -> false
        missingFrom: sinon.stub().withArgs(["pt", "en"], true).returns([])

      sinon.stub(sdp, "localInfo").withArgs("path").returns(W info)

      testSeach [
        [["info", info]]
      ], "unchanged"

    describe "given there are files to upload", ->
      beforeEach (sinon) ->
        info =
          subtitles: ["pt"]
          hasSubtitles: -> true
          pathForLanguage: sinon.stub().withArgs("pt").returns("subpath")
          missingFrom: sinon.stub().withArgs(["pt", "en"], true).returns([])

        sinon.stub(sdp, "localInfo").withArgs("path").returns(W info)

      it "raises error when upload raises an error", (sinon) ->
        sinon.stub(sdp, "upload").withArgs("path", "subpath").returns(W.reject "upload error")

        testSeach [
          [["info", info]]
          [["upload", "subpath"]]
        ], "upload error", true

      it "keeps unchanged status when upload returns cached", (sinon) ->
        sinon.stub(sdp, "upload").withArgs("path", "subpath").returns(W "cached")

        testSeach [
          [["info", info]]
          [["upload", "subpath"]]
        ], "unchanged"

      it "returns the uploaded status when some subtitle got uploaded", (sinon) ->
        sdp.upload = quickStub("path", "subpath", W [status: "uploaded"])

        testSeach [
          [["info", info]]
          [["upload", "subpath"]]
        ], "uploaded"

    describe "given that are missing subtitles", ->
      beforeEach (sinon) ->
        info =
          hasSubtitles: -> false
          missingFrom: sinon.stub().withArgs(["pt", "en"], true).returns(["pt"])
          pathForLanguage: sinon.stub().withArgs("pt").returns("dest")

        sinon.stub(sdp, "localInfo").withArgs("path").returns(W info)

      it "resolves into notfound when no source is able to find a new subtitle", (sinon) ->
        sinon.stub(sdp, "search").withArgs("path", ["pt"]).returns(W null)

        testSeach [
          [["info", info]]
          [["search", ["pt"]]]
        ], "notfound"

      it "rejects when search fails", (sinon) ->
        sinon.stub(sdp, "search").withArgs("path", ["pt"]).returns(W.reject "err")

        testSeach [
          [["info", info]]
          [["search", ["pt"]]]
        ], "err", true

      describe "given the search returns a result", ->
        subtitle = null

        beforeEach (sinon) ->
          subtitle =
            language: -> "pt"
            source: {id: -> "id"}

          sinon.stub(sdp, "search").withArgs("path", ["pt"]).returns(W subtitle)

        it "rejects when download fails", (sinon) ->
          sinon.stub(sdp, "download").withArgs(subtitle, "dest").returns(W.reject "down err")

          testSeach [
            [["info", info]]
            [["search", ["pt"]]]
            [["download", subtitle]]
          ], "down err", true

        describe "given the download was complete", ->
          it "runs the entire process and return status downloaded", (sinon) ->
            sinon.stub(sdp, "download").withArgs(subtitle, "dest").returns(W null)
            sinon.stub(sdp, "cacheDownload").withArgs("dest").returns(W true)
            sdp.upload = -> W true

            testSeach [
              [["info", info]]
              [["search", ["pt"]]]
              [["download", subtitle]]
              [["share", subtitle]]
            ], "downloaded"
