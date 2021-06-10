#!/usr/bin/env liquidsoap
s = buffer(input.http("http://..."))
output.pulseaudio(s)
