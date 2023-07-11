#!./liquidsoap
log.level := 4; s = playlist("~/Music") output.file(fallible=true,
%gstreamer(channels=2, audio="lamemp3enc", video="", muxer="")
, "/tmp/out", s)
