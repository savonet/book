#!./liquidsoap
log.level.set(4) s = playlist("~/Music") output.file(fallible=true,
%gstreamer(audio="lamemp3enc", video="",
           muxer="id3v2mux name='metadata'")
, "/tmp/out", s)
