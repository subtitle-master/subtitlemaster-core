module.exports = class SubDBSubtitle
  constructor: (@lang, @hash, @source) ->
  contentStream: -> @source.api.download(@hash, @contentLanguage())
  language: -> @lang
  contentLanguage: -> if @language() == "pb" then "pt" else @language()
