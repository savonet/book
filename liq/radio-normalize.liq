#!/usr/bin/env liquidsoap
radio = playlist("/radio/day.pls")
radio = normalize(radio)
output(radio)
