#!./liquidsoap
log.level := 5; video.frame.width := 640; video.frame.height := 360; %include "ffmpeg-effect3.liq"
s = single("lf.mp4")
s = myfilter(s)
output.file(fallible=true,
  %ffmpeg(format="matroska",
    %audio.raw(codec="libmp3lame"),
    %video.raw(codec="libx264")),
  "/tmp/out.mkv", s)
