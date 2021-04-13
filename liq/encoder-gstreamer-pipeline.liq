#!./liquidsoap
log.level.set(4) s = playlist("~/Music") output.file(fallible=true,
%gstreamer(pipeline="appsrc name=\"audio_src\" block=true
  caps=\"audio/x-raw,format=S16LE,layout=interleaved,
  channels=1,rate=44100\"
  format=time ! lamemp3enc !
  appsink name=sink sync=false emit-signals=true", has_video=false)
, "/tmp/out", s)
