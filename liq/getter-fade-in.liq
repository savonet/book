#!/usr/bin/env liquidsoap
fade_duration  = 5.
frame_duration = settings.frame.duration()
v = ref(0.)

def volume ()
  v := v() + frame_duration / fade_duration
  if v() > 1. then v := 1. end
  log.important("Volume is now #{v()}")
  v()
end

s = amplify(volume, sine())
output(s)
