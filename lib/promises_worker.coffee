W       = require("when")
timeout = require("when/timeout")

module.exports = class PromisesWorker
  constructor: (@limit, {@timeout} = {}) ->
    @workingCount = 0
    @queue = []

  push: (job) =>
    if @workingCount < @limit
      @workingCount += 1

      @wrapPromise(@_setTimeout(job.run()))
    else
      defer = W.defer()
      @queue.push(job: job, defer: defer)

      defer.promise

  wrapPromise: (promise) =>
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

  workerDone: =>
    @workingCount -= 1

    if @queue.length
      {job, defer} = @queue.shift()

      defer.resolve(@push(job))

  _setTimeout: (promise) => if @timeout then timeout(@timeout, promise) else promise
