md5 = libRequire("hashes/md5.coffee")

describe "MD5 Hash", ->
  it "reject when path doesn't exists", ->
    expect(md5.fromPath("invalid")).hold.reject()

  it "correct calculates the md5 for a valid file", ->
    expect(md5.fromPath(fixture "dexter.mp4")).eq "5bb798f7d3ed095492dca31bcf0155fd"
