_      = require("lodash")
W      = require("when")
util   = libRequire("util")
Stream = require("stream")
concat = require("concat-stream")

describe "Utilities", ->
  describe "promisedPipe", ->
    it "resolves after the pipe is done", ->
      output = ""

      other =
        write: (string) -> output += string
        contents: -> output

      fakeStream = new Stream()
      fakeStream.pipe = (other) ->
        other.write("test")
        _.defer => @emit("end")

      util.promisedPipe(fakeStream, other).then (res)->
        expect(res).eql "test"

  describe "hashToUrlParams", ->
    {hashToUrlParams} = util

    it "returns an empty string for blank values", ->
      expect(hashToUrlParams(null)).eq ""
      expect(hashToUrlParams({})).eq ""
      expect(hashToUrlParams(false)).eq ""

    it "converts object maps into URL query", ->
      expect(hashToUrlParams({a: "b"})).eq "a=b"
      expect(hashToUrlParams({a: "b", c: "d"})).eq "a=b&c=d"

  describe "allFulfilled", ->
    {allFulfilled} = util

    err = -> W.reject(new Error("error"))

    it "resolves fulfilled promises and filter others", ->
      expect(allFulfilled([])).eql []
      expect(allFulfilled([W 1])).eql [1]
      expect(allFulfilled([err()])).eql []
      expect(allFulfilled([W(2), err(), err(), W(3)])).eql [2, 3]

  describe "directoryStream", ->
    it "returns a stream that emits directory contents", ->
      stream = util.directoryStream(fixture('scanner'))

      expect(stream).streamChunks.eql [
        fixture('scanner/imfile')
        fixture('scanner/flat/Breaking.Bad.S05E03.mkv')
        fixture('scanner/flat/Friends.S02E25.mkv')
        fixture('scanner/flat/notvideo.txt')
      ]
