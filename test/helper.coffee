process.env.NODE_ENV = "test"

require("better-stack-traces").install()

path  = require("path")
sinon = require("sinon")

lazy "sinon", -> sinon.sandbox.create()
lazy "spy", (sinon) -> sinon.spy()
afterEach (sinon) -> sinon.restore()

lazy "get", -> (property) -> (obj) -> obj[property]
lazy "invoke", -> (method, args...) -> (obj) -> obj[method](args...)

global.libRequire = (libPath) -> require(path.join("..", "lib", libPath))
global.fixture = (fixture) -> path.join __dirname, "fixtures", fixture
global.quickStub = (args..., result) -> (calledArgs...) ->
  expect(calledArgs).eql(args)
  result

_ = require("lodash")
fs = require("fs")

class Flagger
  constructor: (@target) -> @target.__flags ||= {}

  get: (flag) -> @target.__flags[flag]
  set: (flag, value) -> @target.__flags[flag] = value

flagger = (object) -> new Flagger(object)

skipFlags = (flagsToSkip...) -> (test) ->
  flag = flagger(test)
  flag.set("skip", true) if _.any flagsToSkip, flag.get, flag

if fs.existsSync(path.join(__dirname, "..", "tmp", "quicktest"))
  BarrierRunner.on "test", skipFlags("remote")
