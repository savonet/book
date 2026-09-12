#!/usr/bin/env liquidsoap
radio = playlist("/radio/day.pls")
radio = nrj(radio)
output(radio)
