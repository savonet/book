#!/usr/bin/env liquidsoap
s = input.http("http://...")
# header
s = fallback([s, blank()])
# footer
output.pulseaudio(s)
