#!./liquidsoap
log.level.set(5) video.frame.width.set(640) video.frame.height.set(360) %include "ffmpeg-effect3.liq"
s = single("lf.mp4")
s = myfilter(s)
output.file(fallible=true,
  %ffmpeg(format="matroska",
    %audio.raw(codec="libmp3lame"),
    %video.raw(codec="libx264")),
  "/tmp/out.mkv", s)
