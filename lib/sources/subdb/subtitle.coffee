module.exports = class SubDBSubtitle
  constructor: (@lang, @hash, @version, @source) ->
  contentStream: -> @source.api.download(@hash, @contentLanguage(), @version)
  language: -> @lang
  contentLanguage: -> if @language() == "pb" then "pt" else @language()

  toString: -> "SubDB Subtitle #{@hash} v#{@version}"
