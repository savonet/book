#!./liquidsoap -i

def myfilter(s) =
  def mkfilter(graph) =
    s = ffmpeg.filter.video.input(graph, s)
    s = ffmpeg.filter.hflip(graph, s)
    s = ffmpeg.filter.curves(preset=10, graph, s)
    ffmpeg.filter.video.output(graph, s)
  end
  f = ffmpeg.raw.decode.video(ffmpeg.filter.create(mkfilter))
  mux_audio(audio=drop_video(s), f)
end

s = single("webcam.mkv")
s = myfilter(s)
output.audio_video(s)