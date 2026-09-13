#!/usr/bin/env liquidsoap
radio = playlist("/radio/day.pls")
# header
radio = crossfade(fade_out=3., fade_in=3., duration=5., radio)
# footer
output(radio)
