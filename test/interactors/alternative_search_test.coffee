AlternativeSearch = libRequire('interactors/alternative_search.coffee')

describe 'AlternativeSearch', ->
  it 'returns a list with all subtitle results', ->
    search = new AlternativeSearch('path.mkv', ['en', 'pt'])
    search.engine =
      search: quickStub('path.mkv', ['en', 'pt'], ['a', 'b'])

    expect(search.run()).eql ['a', 'b']
