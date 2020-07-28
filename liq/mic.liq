#!/usr/bin/env liquidsoap
s = buffer(input.alsa())
output(s)