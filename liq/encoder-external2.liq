#!./liquidsoap
s = playlist("~/Music") s = mux_video(video=video.fill(color=0xff0000, blank()), s) output.file(fallible=true,
%external(process="ffmpeg -i pipe:0 -f avi pipe:1", video=true)
, "/tmp/out", s)
