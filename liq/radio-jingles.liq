#!/usr/bin/env liquidsoap
radio   = playlist("/radio/day.pls")
# header
jingles = playlist("/radio/jingles.pls")
radio   = random([jingles, radio.{weight = 4}])
# footer
output(radio)
