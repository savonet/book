def myfilter(s) =
  def mkfilter(graph) =
    s = ffmpeg.filter.video.input(graph, s)
    s = ffmpeg.filter.hflip(graph, s)
    s = ffmpeg.filter.curves(preset=10, graph, s)
    ffmpeg.filter.video.output(graph, s)
  end
   mux_audio(audio=drop_video(s), ffmpeg.filter.create(mkfilter))
end
