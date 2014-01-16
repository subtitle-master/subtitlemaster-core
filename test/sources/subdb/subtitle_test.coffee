Subtitle = libRequire("sources/subdb/subtitle.coffee")

describe "SubDBSubtitle", ->
  it "do the correct request for the download", ->
    request = quickStub(hash = "hash", lang = "en", stream = "STREAM")
    sub = new Subtitle(lang, hash, {api: {download: request}})

    expect(sub.contentStream()).eq stream

  it "returns the language as a function", ->
    sub = new Subtitle(lang = "en")
    expect(sub.language()).eq lang
