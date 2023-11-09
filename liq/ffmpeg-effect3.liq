def myfilter(s) =
  def mkfilter(graph) =
    a = ffmpeg.filter.audio.input(graph, source.tracks(s).audio)
    a = ffmpeg.filter.flanger(graph, a)
    a = ffmpeg.filter.audio.output(graph, a)

    v = ffmpeg.filter.video.input(graph, source.tracks(s).video)
    v = ffmpeg.filter.hflip(graph, v)
    v = ffmpeg.filter.negate(graph, v)
    v = ffmpeg.filter.video.output(graph, v)

    source({
      audio = a,
      video = v,
      metadata = track.metadata(a),
      track_marks = track.track_marks(a)
    })
  end
  ffmpeg.filter.create(mkfilter)
end
