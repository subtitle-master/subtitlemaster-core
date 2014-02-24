MediaInfo = libRequire('media_info.coffee')

describe 'MediaInfo', ->
  lazy 'info', -> new MediaInfo()

  it 'returns null when the file doesnt match', (info) ->
    expect(info.from('path.mkv')).null

  it 'extracts media info when its present', (info) ->
    expect(info.from(path = 'how.i.met.your.mother.s09e16.720p.hdtv.x264-killers.mkv')).eql
      path: path
      name: 'how i met your mother'
      season: 9

  it 'removes directory from the path on the name', (info) ->
    expect(info.from(path = '/some/path/inside/how.i.met.your.mother.s09e16.720p.hdtv.x264-killers.mkv')).eql
      path: path
      name: 'how i met your mother'
      season: 9

  it 'ignores sample files', (info) ->
    expect(info.from('how.i.met.your.mother.s09e16.720p.hdtv.x264-killers.sample.mkv')).null

  it 'ignores non-video files', (info) ->
    expect(info.from('how.i.met.your.mother.s09e16.720p.hdtv.x264-killers.srt')).null
    expect(info.from('how.i.met.your.mother.s09e16.720p.hdtv.x264-killers.rar')).null
