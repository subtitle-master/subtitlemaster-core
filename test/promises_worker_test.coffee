W = require("when")

PromisesWorker = libRequire("promises_worker.coffee")

describe "PromisesWorker", only: true, ->
  lazy "worker", -> new PromisesWorker(1)

  class SimpleJob
    constructor: (@fn) -> @started = false
    run: ->
      @started = true
      @fn()

  it "runs a job direct when the worker count is under limit", (worker) ->
    defer = W.defer()
    res = worker.push(job = new SimpleJob(-> defer.promise))

    expect(job.started).true

    defer.resolve("result")

    expect(res).eq "result"

  it "doesn't run if the workers are full", (worker) ->
    defer = W.defer()
    res = worker.push(new SimpleJob(->))
    res = worker.push(job = new SimpleJob(-> defer.promise))

    expect(job.started).false

  it "run the job when the queue has added limit", (worker) ->
    defer = W.defer()
    res = worker.push(new SimpleJob(-> defer.promise))
    worker.push(job = new SimpleJob(-> W null))

    expect(job.started).false

    defer.resolve("anything")

    defer.promise.then ->
      expect(job.started).true

  it "run the job when the queue has added limit for a failed task", (worker) ->
    defer = W.defer()
    res = worker.push(new SimpleJob(-> defer.promise))
    worker.push(job = new SimpleJob(-> W null))

    expect(job.started).false

    defer.reject(new Error("anything"))

    defer.promise.then undefined, ->
      expect(job.started).true

  it "runs all the jobs", (worker) ->
    defer1 = W.defer()
    defer2 = W.defer()

    res1 = worker.push(new SimpleJob(-> defer1.promise))
    res2 = worker.push(new SimpleJob(-> defer2.promise))

    defer1.resolve("one")
    defer2.resolve("two")

    res2.then (res) -> expect(res).eq "two"
