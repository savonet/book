#!/usr/bin/env liquidsoap
s         = input.http("http://...")
emergency = single("/radio/emergency.mp3")
s         = fallback(track_sensitive=false, [s, emergency])
output.pulseaudio(s)
