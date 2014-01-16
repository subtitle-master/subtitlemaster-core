_ = require("lodash")
util = libRequire("util")
Stream = require("stream")

describe "Utilities", ->
  describe "promisedPipe", ->
    it "resolves after the pipe is done", ->
      output = ""

      other =
        write: (string) -> output += string

      fakeStream = new Stream()
      fakeStream.pipe = (other) ->
        other.write("test")
        _.defer => @emit("end")

      util.promisedPipe(fakeStream, other).then ->
        expect(output).eql "test"

  describe "hashToUrlParams", ->
    {hashToUrlParams} = util

    it "returns an empty string for blank values", ->
      expect(hashToUrlParams(null)).eq ""
      expect(hashToUrlParams({})).eq ""
      expect(hashToUrlParams(false)).eq ""

    it "converts object maps into URL query", ->
      expect(hashToUrlParams({a: "b"})).eq "a=b"
      expect(hashToUrlParams({a: "b", c: "d"})).eq "a=b&c=d"
