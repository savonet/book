#!/usr/bin/env liquidsoap
radio = mksafe(playlist("/radio/day.pls"))
# header
output(radio)
