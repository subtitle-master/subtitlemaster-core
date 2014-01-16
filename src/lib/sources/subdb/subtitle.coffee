module.exports = class SubDBSubtitle
  constructor: (@lang, @hash, @source) ->
  contentStream: -> @source.api.download(@hash, @language())
  language: -> @lang
