#!/usr/bin/env liquidsoap
radio = playlist("/radio/day.pls")
# header
radio = normalize(radio)
# footer
output(radio)
