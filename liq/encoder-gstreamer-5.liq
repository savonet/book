#!./liquidsoap
log.level := 5; s = playlist("~/Music") output.file(fallible=true,
%gstreamer(audio="vorbisenc", video="theoraenc", muxer="oggmux")
, "/tmp/out", s)
