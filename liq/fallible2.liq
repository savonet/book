#!/usr/bin/env liquidsoap
# header
s         = input.http("http://...")
emergency = single("/radio/emergency.mp3")
s         = fallback([s, emergency])
output.pulseaudio(s)
