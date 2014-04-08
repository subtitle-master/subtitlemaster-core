W = require('when')

OrganizeMedia = libRequire('interactors/organize_media.coffee')

describe 'OrganizeMedia', ->
  it 'returns blank for blank directory', ->
    organizer = new OrganizeMedia()

    source = fixture('scanner/empty')
    target = fixture('scanner/empty')

    expect(organizer.scan(source, target)).eql []

  describe 'readTargetShows', ->
    it 'returns the directories from a path', ->
      organizer = new OrganizeMedia()
      organizer.target = fixture('scanner')

      expect(organizer.readTargetShows()).eql ['empty', 'flat']

  describe 'matchTarget', ->
    it 'match renaming the show according to best match', ->
      info = name: 'Show Name', season: 2, path: 'original/video/path.mkv'

      organizer = new OrganizeMedia()
      organizer.target = 'target'
      organizer.findBestMatch = quickStub(info.name, W {name: 'New Name', isNew: true})

      organizer.matchTarget(info).then (entry) ->
        expect(entry).property('newShow', true)
        expect(entry).property('source', 'original/video/path.mkv')
        expect(entry).property('target', 'target/New Name/Season 02/path.mkv')

  describe 'findBestMatch', ->
    testBestMatch = (shows, name, isNew, newName) ->
      organizer = new OrganizeMedia()
      organizer._targetShows = -> W shows
      organizer.findBestMatch(name).then (best) ->
        expect(best).property('isNew', isNew)
        expect(best).property('name', newName)

    it 'returns the show name and true when the show is not present', ->
      testBestMatch([], 'Some Show', true, 'Some Show')

    it 'returns false if the show is present on the list', ->
      testBestMatch(['Some Show'], 'Some Show', false, 'Some Show')

    it 'capitalizes words for new shows', ->
      testBestMatch([], 'baD cAPitaLized TiTle', true, 'Bad Capitalized Title')

    it 'matches regardless case', ->
      testBestMatch(['How I Met You'], 'how i Met you', false, 'How I Met You')
