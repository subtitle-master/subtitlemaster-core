_ = require("lodash")
Path = require("path")

Scanner = libRequire("video_scanner")

sp = (path) -> "#{__dirname}/fixtures/scanner/#{path}"
relativize = (paths, base = "") -> _.map _.pluck(paths, "path"), (p) -> Path.relative(sp(base), p)

describe "Video Scanner", ->
  lazy "scanner", -> new Scanner()
  lazy "lookup", (path, scanner) -> scanner.lookup(sp path)

  describe "given invalid path", ->
    it "raises an error", (scanner) -> expect(-> scanner.lookup(sp "invalid")).reject()

  describe "given path is not a directory", ->
    it "raises an error", (scanner) -> expect(-> scanner.lookup(sp "imfile")).reject()

  describe "scanning empty directory", ->
    lazy "path", -> "empty"

    it "returns a blank array", (lookup) -> expect(lookup).eql([])

  describe "scanning flat directory", ->
    lazy "path", -> "flat"

    it "returns video files", (lookup) ->
      lookup = relativize(lookup, "flat")

      expect(lookup).include.members(["Friends.S02E25.mkv", "Breaking.Bad.S05E03.mkv", "notvideo.txt"])

  describe "scanning with filters", ->
    lazy "path", -> "flat"

    txtFilter     = check: (path) -> /\.txt/.test(path)
    mkvFilter     = check: (path) -> /\.mkv/.test(path)
    friendsFilter = check: (path) -> /Friends/.test(path)

    it "filter with the results", (scanner) ->
      scanner.filters.push(txtFilter)
      scanner.lookup(sp "flat")
        .then((files) -> relativize(files, "flat"))
        .then((files) -> expect(files).eql(["notvideo.txt"]))

    it "runs multiple filters", (scanner) ->
      scanner.filters.push(mkvFilter)
      scanner.filters.push(friendsFilter)
      scanner.lookup(sp "flat")
        .then((files) -> relativize(files, "flat"))
        .then((files) -> expect(files).eql(["Friends.S02E25.mkv"]))

    it "stop running filters on first fail", (scanner, sinon) ->
      spy = sinon.spy()

      scanner.filters.push(txtFilter)
      scanner.filters.push(check: spy)
      scanner.lookup(sp "flat").then -> expect(spy.callCount).eq(1)

    it "can collect information from the filters", (scanner) ->
      infoFilter = check: (p) ->
        p.info.show = "Name"
        true

      scanner.filters.push(infoFilter)
      scanner.lookup(sp "flat").then (paths) -> expect(paths[0]).deep.property("info.show", "Name")

    it "have access to the original path", (lookup, path) ->
      expect(lookup[0]).deep.property("info.basePath", sp path)
