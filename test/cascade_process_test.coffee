W     = require("when")
delay = require("when/delay")

cascade = libRequire("cascade_process")

describe "Cascade Process", ->
  it "without filters returns an object with input value and blank info", ->
    cascade(1).then ({value, info}) ->
      expect(value).eq 1
      expect(info).eql {}

  it "filters can add information", ->
    simpleInfoFilter = ({value, info}) -> info.x = 2

    cascade(1, [simpleInfoFilter]).then ({value, info}) ->
      expect(value).eq 1
      expect(info).property("x", 2)

  it "filters can invalidate the result by returning false", ->
    invalidateFilter = -> false

    expect(cascade(1, [invalidateFilter])).false

  it "filters errors propragates to the promise result", ->
    errorFilter = -> throw 'error'

    expect(cascade(1, [errorFilter])).hold.reject('error')

  it "filters can be promises", ->
    promiseFilter = ({value, info}) -> delay(0).then -> info.y = 2

    expect(cascade(1, [promiseFilter])).deep.property("info.y", 2)

  it "rejects when a filter returns a rejected promise", ->
    errorFilter = -> W.reject("error")

    expect(cascade(1, [errorFilter])).hold.reject('error')
