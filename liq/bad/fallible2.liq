#!/usr/bin/env liquidsoap
s         = buffer(input.http("http://..."))
emergency = single("/radio/emergency.mp3")
s         = fallback(track_sensitive=false, [s, emergency])
output.pulseaudio(s)
