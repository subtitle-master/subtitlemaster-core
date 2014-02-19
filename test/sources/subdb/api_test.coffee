W   = require("when")
API = libRequire("sources/subdb/api.coffee")
fs  = require("fs")

readStream = (stream) ->
  W.promise (resolve) ->
    buf = ""
    stream.on "data", (chunk) -> buf += chunk
    stream.on "end", -> resolve(buf)

describe "SubDBAPI", skip: true, ->
  it "initializes with the given endpoint", ->
    api = new API(ep = "endpoint")
    expect(api.endpoint).eq ep

  describe "integration", remote: true, ->
    HASH = "edc1981d6459c6111fe36205b4aff6c2"

    lazy "api", -> new API("http://sandbox.thesubdb.com/")

    it "searches for the subtitle", (api) ->
      expect(api.search(HASH)).eql ['en', 'es', 'fr', 'it', 'pt']

    it "downloads a subtitle", (api) ->
      content = fs.readFileSync(fixture "subdb-download.srt", encoding: "utf8")

      expect(readStream(api.download(HASH, "en"))).string(content)

    it "uploads a subtitle", (api) ->
      hash = "edc1981d6459c6111fe36205b4aff6c3"
      stream = fs.createReadStream(fixture "subdb-download.srt")

      expect(api.upload(hash, stream)).property("statusCode", 201)
