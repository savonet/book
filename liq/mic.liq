#!/usr/bin/env liquidsoap
s = buffer(input.alsa())
out(s)