def myfilter(s) =
  def mkfilter(graph) =
    v = ffmpeg.filter.video.input(graph, s.video)
    v = ffmpeg.filter.hflip(graph, v)
    v = ffmpeg.filter.curves(preset=10, graph, v)
    ffmpeg.filter.video.output(graph, v)
  end
  source(s.{video=ffmpeg.filter.create(mkfilter)})
end
