#!./liquidsoap
video.frame.width.set(640)
video.frame.height.set(360)
def myfilter(s) =
  def mkfilter(graph) =
    s = drop_audio(s)
    s = ffmpeg.raw.encode.video(%ffmpeg(%video.raw), s)
    s = ffmpeg.filter.video.input(graph, s)
    s = ffmpeg.filter.hflip(graph, s)
    s = ffmpeg.filter.curves(preset=10, graph, s)
    ffmpeg.filter.video.output(graph, s)
  end
  o = ffmpeg.raw.decode.video(ffmpeg.filter.create(mkfilter))
  mux_audio(audio=drop_video(s), o)
end
s = single("lf.mp4")
s = myfilter(s)
output.audio_video(s)
