def myfilter(s) =
  def mkfilter(graph) =
    a = ffmpeg.filter.audio.input(graph, source.tracks(s).audio)
    a = ffmpeg.filter.flanger(graph, a)
    a = ffmpeg.filter.audio.output(graph, a)

    v = ffmpeg.filter.video.input(graph, source.tracks(s).video)
    v = ffmpeg.filter.hflip(graph, v)
    v = ffmpeg.filter.negate(graph, v)
    v = ffmpeg.filter.video.output(graph, v)

    s = source.mux.track.audio(audio=a, s)
    s = source.mux.track.video(video=v, s)
    s
  end
  ffmpeg.filter.create(mkfilter)
end
