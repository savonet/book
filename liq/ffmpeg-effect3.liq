#!./liquidsoap
def myfilter(s) =
  def mkfilter(graph) =
    s = ffmpeg.raw.encode.video(%ffmpeg(format="rawvideo", %video.raw), s)
    s = ffmpeg.filter.video.input(graph, s)
    s = ffmpeg.filter.hflip(graph, s)
    s = ffmpeg.filter.curves(preset=10, graph, s)
    ffmpeg.filter.video.output(graph, s)
  end
  s = ffmpeg.raw.decode.video(ffmpeg.filter.create(mkfilter))
  mux_audio(audio=drop_video(s), s)
end
s = single("lf.mp4")
s = myfilter(s)
output.audio_video(s)