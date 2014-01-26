W   = require("when")
API = libRequire("sources/open_subtitles/api.coffee")

describe "OpenSubtitles API", timeout: 10000, ->
  UA = "Subtitle Master v2.0.0.test"
  lazy "api", -> new API(UA)

  checkResponse = (res) ->
    expect(res).property("status", "200 OK")
    expect(res).property("seconds")

  describe "auth", ->
    describe "given the response is a valid token", ->
      beforeEach (api) -> api.LogIn = quickStub(W status: "200 OK", token: "123")

      it "calls the login and saves the token", (api) ->
        api.auth().then -> expect(api.authToken).eq "123"

    describe "given the response is invalid", ->
      beforeEach (api) -> api.LogIn = quickStub(W status: "404")

      it "rejects an error", (api) ->
        expect(api.auth()).hold.reject("Can't login on OpenSubtitles")

  describe "search", ->
    describe "given authentication pass", ->
      beforeEach (api) -> api.ensureAuth = -> W "token"

      it "returns the search result", (api) ->
        api.SearchSubtitles = quickStub("token", "query", W data: "result")
        expect(api.search("query")).property("data", "result")

  describe "ensureAuth", ->
    describe "given there is an auth token", ->
      it "returns it", (api) ->
        api.authToken = "token"
        expect(api.ensureAuth()).eq "token"

    describe "given there is no authtoken", ->
      it "calls login and return the new token", (api) ->
        api.auth = quickStub W "tokenL"
        expect(api.ensureAuth()).eq "tokenL"

  describe "server calls", remote: true, ->
    describe "LogIn", ->
      it "correctly calls the login", (api) ->
        api.LogIn().then (res) ->
          checkResponse(res)
          expect(res).property("token")

    describe "SearchSubtitles", ->
      lazy "authToken", (api) -> api.LogIn().then ({token}) -> token

      it "correctly calls the server", (api, authToken) ->
        query = [
          sublanguageid: "pob,eng"
          moviehash:     "cf2490e0d1ecddb6"
          moviebytesize: 833134592
        ]

        api.SearchSubtitles(authToken, query).then (res) ->
          checkResponse(res)
          expect(res).property("data").length.gt(0)
