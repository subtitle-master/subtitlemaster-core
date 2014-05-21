_ = require('lodash')
W = require('when')

AlternativeSearch = libRequire('interactors/alternative_search.coffee')

describe 'AlternativeSearch', ->
  describe 'run', ->
    it 'returns a list containing subtitle information and downloaded paths', ->
      search = new AlternativeSearch('path.mkv', ['en', 'pt'])
      search.engine =
        search: quickStub('path.mkv', ['en', 'pt'], W ['a', 'b'])

      search.downloadSubtitles = (subtitles) ->
        _.map subtitles, (s) -> {path: "#{s}path.srt", subtitle: s}

      expect(search.run()).eql [{path: 'apath.srt', subtitle: 'a'}, {path: 'bpath.srt', subtitle: 'b'}]

  describe 'downloadSubtitles', ->
    search = null

    beforeEach ->
      search = new AlternativeSearch()

    it 'returns a blank list when there is nothing to download', ->
      expect(search.downloadSubtitles([])).eql []

    describe 'with results', ->
      subtitle = contentStream: -> 'stream'

      it 'downloads a subtitle and return its result', ->
        search.download = quickStub(subtitle, W 'res')

        expect(search.downloadSubtitles([subtitle])).eql ['res']

      it 'removes rejected results', ->
        search.download = quickStub(subtitle, W.reject(new Error("error")))

        expect(search.downloadSubtitles([subtitle])).eql []

  describe 'download', ->
    it 'pipes streams and returns a download result', ->
      subtitle =
        language: -> "en"
        contentStream: -> 'stream'

      path = 'path'
      sourcePath = '/path/to/file/original.mkv'
      targetPath = '/path/to/file/original.en.srt'

      search = new AlternativeSearch(sourcePath)
      search._writeStream = quickStub(targetStream = {path})
      search._pipe = quickStub('stream', targetStream, W null)

      search.download(subtitle).then (download) ->
        expect(download).eql {path, subtitle, sourcePath, targetPath}
