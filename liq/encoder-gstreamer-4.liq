#!./liquidsoap
log.level.set(4) s = playlist("~/Music") output.file(fallible=true,
%gstreamer(audio="lamemp3enc", video="x264enc", muxer="mpegtsmux")
, "/tmp/out", s)
