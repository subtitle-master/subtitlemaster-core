{fromPath} = libRequire("hashes/md5_edges.coffee")

describe "Edge 128 bits MD5 hash", ->
  VIDEO_FIXTURES = [{
    path: fixture "sample1.file"
    hash: "799fe265563e2150ee0e26f1ea0036c2"
  }, {
    path: fixture "sample2.file"
    hash: "2585d99169ddf3abc5708c638771dc85"
  }]

  for info in VIDEO_FIXTURES
    it "generates correct hash for #{info.path}", ->
      expect(fromPath(info.path)).eq(info.hash)
