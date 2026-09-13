#!/usr/bin/env liquidsoap
# header
s = input.http("http://...")
output.pulseaudio(s)
