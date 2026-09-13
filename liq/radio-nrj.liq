#!/usr/bin/env liquidsoap
radio = playlist("/radio/day.pls")
# header
radio = nrj(radio)
# footer
output(radio)
