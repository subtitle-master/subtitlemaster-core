osHash = libRequire("hashes/open_subtitles.coffee")

describe "OpenSubtitles Hash", ->
  it "reject when the file doesn't exists", ->
    expect(osHash.fromPath("invalid")).hold.reject()

  it "generates the hash for a valid path", ->
    expect(osHash.fromPath(fixture "breakdance.avi")).eql ["8e245d9679d31e12", 12909756]
