SearchEngine = require("../search_engine")

module.exports = class AlternativeSearch
  constructor: (@path, @languages) ->
    @engine = new SearchEngine()

  run: -> @engine.search(@path, @languages)
