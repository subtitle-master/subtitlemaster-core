W = require("when")

module.exports = class PromisesWorker
  constructor: (@limit) ->
    @workingCount = 0
    @queue = []

  push: (job) ->
    if @workingCount < @limit
      @workingCount += 1

      @wrapPromise(job.run())
    else
      @queue.push(job)

  wrapPromise: (promise) ->
    W.promise (resolve, reject, notify) =>
      promise.then(
        (res) =>
          @workerDone()
          resolve(res)

        (err) =>
          @workerDone()
          reject(err)

        (msg) => notify(msg)
      )

  workerDone: ->
    @workingCount -= 1
    @push(@queue.shift()) if @queue.length
