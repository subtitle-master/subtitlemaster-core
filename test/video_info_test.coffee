Video = libRequire("video_info")

describe "Video Info", ->
  describe "initializes", ->
    path = "#{__dirname}/fixtures/sample1.file"
    video = null

    it "with path", ->
      video = new Video(path)
      expect(video.path).to.eq(path)
