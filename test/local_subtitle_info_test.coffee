subInfo = libRequire("local_subtitle_info")

describe "Local Subtitle Info", ->
  lazy "path", -> ""
  lazy "videoPath", (path) -> "#{__dirname}/fixtures/#{path}"
  lazy "info", (videoPath) -> subInfo(videoPath)

  describe "path without subtitles", ->
    lazy "path", -> "clip1.mkv"

    it "has the original path", (info, videoPath) ->
      expect(info.path).to.eq(videoPath)

    it "returns false for hasSubtitles", (info) ->
      expect(info.hasSubtitles()).to.be.false

    it "returns blank list for subtitles", (info) ->
      expect(info.subtitles).to.eql([])

    it "can build the subtitle path for a given language", (info) ->
      expect(info.pathForLanguage("en")).to.eq("#{__dirname}/fixtures/clip1.en.srt")

    it "can build the subtitle path for no language", (info) ->
      expect(info.pathForLanguage(null)).to.eq("#{__dirname}/fixtures/clip1.srt")

  describe "path with simple subtitle", ->
    lazy "path", -> "clip-subtitled.mkv"

    it "returns true for hasSubtitles", (info) ->
      expect(info.hasSubtitles()).to.be.true

    it "returns list for subtitles with null", (info) ->
      expect(info.subtitles).to.eql([null])

  describe "path with localized subtitles", ->
    lazy "path", -> "white.mkv"

    it "returns true for hasSubtitles", (info) ->
      expect(info.hasSubtitles()).to.be.true

    it "returns list for subtitles with null", (info) ->
      expect(info.subtitles).to.eql(["en"])

    it "returns a filtered list with unavaiable languages", (info) ->
      expect(info.missingFrom(["pb", "en", "es"])).to.eql(["pb", "es"])

  describe "path with multiple localized subtitles", ->
    lazy "path", -> "famous.mkv"

    it "returns a filtered list with unavaiable languages", (info) ->
      expect(info.missingFrom(["pb", "en", "pt", "es"])).to.eql(["pb", "es"])

    it "returns a filtered list with unavaiable languages discarding right", (info) ->
      expect(info.missingFrom(["pb", "en", "pt", "es"], true)).to.eql(["pb"])

    it "returns a filtered list with unavaiable languages discarding right", (info) ->
      expect(info.missingFrom(["en", "pb", "pt", "es"], true)).to.eql([])

    it "returns a filtered list with unavaiable languages discarding right", (info) ->
      expect(info.missingFrom(["pb", "es", "en", "pt"], true)).to.eql(["pb", "es"])

  describe "path with multiple localized subtitles", ->
    lazy "path", -> "famous.mkv"

    it "return the highest priority", (info) ->
      expect(info.preferred(["pb", "en", "pt", "es"])).eq "en"
      expect(info.preferred(["pt", "en", "pb", "es"])).eq "pt"
      expect(info.preferred(["pb", "es"])).eq null
