SubtitleScore = libRequire("subtitle_score.coffee")

describe 'SubtitleScore', ->
  describe 'calculate subtitle score', ->
    it 'calculates the language score', ->
      rank = new SubtitleScore("path.mkv", ["en", "pt"])
      expect(rank.scoreLanguage({language: -> "en"})).eq 20000
      expect(rank.scoreLanguage({language: -> "pt"})).eq 10000
      expect(rank.scoreLanguage({language: -> "ot"})).eq 0

    it 'sorts the subtitles', ->
      rank = new SubtitleScore("path.mkv", ["en", "pt"])

      sub1 = language: -> 'pt'
      sub2 = language: -> 'en'

      expect(rank.sort([sub1, sub2])).eql [sub2, sub1]
