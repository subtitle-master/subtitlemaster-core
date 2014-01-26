OpenSubtitlesScore = libRequire("sources/open_subtitles/score.coffee")

describe "OpenSubtitlesScore", ->
  describe "#constructor", ->
    it "initializes with info", ->
      score = new OpenSubtitlesScore(info = {})
      expect(score.info).eq info

  describe "#score", ->
    describe "language points", ->
      testLanguageScore = (query, current, score) ->
        scoreInstance = new OpenSubtitlesScore
          QueryParameters:
            sublanguageid: query
          SubLanguageID: current

        expect(scoreInstance.score()).eq score

      it "adds 10000 points if the language is first and only choice", ->
        testLanguageScore("eng", "eng", 10000)

      it "adds 0 if the subtitle language is not on the searches", ->
        testLanguageScore("eng", "pob", 0)

      it "adds 10000 if the language is there on multiple", ->
        testLanguageScore("eng,pob", "pob", 10000)

      it "adds 10000 for each distance", ->
        testLanguageScore("eng,pob,por", "eng", 30000)
        testLanguageScore("eng,pob,por", "pob", 20000)
        testLanguageScore("eng,pob,por", "por", 10000)
        testLanguageScore("eng,pob,por", "oth", 0)
