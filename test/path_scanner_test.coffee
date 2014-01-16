scan = libRequire("path_scanner")

describe "PathScanner", ->
  it "returns a blank result when a blank entry is given", ->
    expect(scan([])).eql []

  it "removes invalid entry from the list", ->
    expect(scan(["invalid"])).eql []

  it "returns the same file entry when it's valid", ->
    famous = fixture("famous.mkv")

    expect(scan([famous])).eql [famous]

  it "fires notify event for valid files", ->
    notifications = []
    famous = fixture("famous.mkv")

    scan([famous]).then(
      (res) -> expect(notifications).eql [famous]
      undefined
      (path) -> notifications.push(path)
    )

  it "fires error when paths is not an array", ->
    expect(-> scan(null)).throw

  it "scans a given directory from the list", ->
    expected = [
      fixture("scanner/flat/Breaking.Bad.S05E03.mkv")
      fixture("scanner/flat/Friends.S02E25.mkv")
      fixture("scanner/flat/notvideo.txt")
    ]

    scan([fixture("scanner/flat")]).then (results) ->
      expect(results).length(expected.length)
      expect(results).members(expected)
