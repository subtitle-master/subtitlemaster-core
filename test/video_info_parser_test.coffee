require('./helper.coffee')

parser = libRequire("video_info_parser")

describe "Video Info Parser", ->
  describe "parsing a simple valid path", ->
    info = null

    before -> info = parser("South.Park.S17E02.720p.HDTV.x264-IMMERSE")

    it "parses the show name", ->
      expect(info).to.have.property("name", "South Park")

    it "parses the season", ->
      expect(info).to.have.property("season", 17)

    it "parses the episode", ->
      expect(info).to.have.property("episode", 2)

  describe "parsing with joined format", ->
    lazy "info", true, -> parser("revenge.307.hdtv-lol")

    it "parse the show name", (info) -> expect(info).property("name", "revenge")
    it "parse the season", (info) -> expect(info).property("season", 3)
    it "parse the episde", (info) -> expect(info).property("episode", 7)

  describe "parsing an invalid path", ->
    it "returns null", -> expect(parser("Ssacsaca")).to.be.null

  testParse = (filename, name, season, episode) ->
    info = parser(filename)

    expect(info).property('name', name)
    expect(info).property('season', season)
    expect(info).property('episode', episode)

  it "parses the examples correctly", ->
    testParse('The.Simpsons.S025E17.720p.HDTV.X264-DIMENSION.mkv', 'The Simpsons', 25, 17)