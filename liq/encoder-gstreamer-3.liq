#!./liquidsoap
log.level.set(4) s = playlist("~/Music") output.file(fallible=true,
%gstreamer(audio="vorbisenc ! vorbistag name='metadata'", video="",
           muxer="oggmux")
, "/tmp/out", s)
