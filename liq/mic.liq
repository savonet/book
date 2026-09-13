#!/usr/bin/env liquidsoap
# header
s = buffer(input.alsa())
output(s)
