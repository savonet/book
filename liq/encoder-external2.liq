#!./liquidsoap
s = single("lf.mp4") output.file(
%external(video=true,
  process="ffmpeg -f avi -i pipe:0 -f matroska \
           -c:v libx264 -c:a libmp3lame pipe:1")
, "/tmp/out.mkv", mksafe(s))
