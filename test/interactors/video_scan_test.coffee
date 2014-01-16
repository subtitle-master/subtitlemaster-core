W     = require("when")
delay = require("when/delay")

VSO = libRequire("interactors/video_scan")

describe "Video Scan Operation", ->
  simpleDriver = (paths) ->
    W.promise (resolve, reject, notify) ->
      setTimeout ->
        notify(path) for path in paths
        setTimeout ->
          resolve(paths)
        , 0
      , 0

  scan = (paths) ->
    results = []

    VSO(paths, driver: simpleDriver).then(
      -> results
      undefined
      (res) -> results.push(res)
    )

  it "removes non video files", ->
    expect(scan(["file.txt"])).eql []

  it "keeps video files", ->
    expect(scan(["file.mkv"])).eql [{value: "file.mkv", info: {}}]

  it "waits for the filters before resolving", ->
    slowFilter = (input) -> delay(10, true)
    log = []

    VSO([1, 2], driver: simpleDriver, filters: [slowFilter]).then(
      -> expect(log).eql [1, 2]
      undefined
      ({value}) -> log.push(value)
    )
