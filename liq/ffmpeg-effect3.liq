def myfilter(s) =
  def mkfilter(graph) =
    a = ffmpeg.filter.audio.input(graph, s)
    a = ffmpeg.filter.flanger(graph, a)

    v = ffmpeg.filter.video.input(graph, s)
    v = ffmpeg.filter.hflip(graph, v)
    v = ffmpeg.filter.negate(graph, v)

    ffmpeg.filter.audio_video.output(graph, a, v)
  end
  ffmpeg.filter.create(mkfilter)
end
