#!/usr/bin/env liquidsoap
radio   = playlist("/radio/day.pls")
jingles = playlist("/radio/jingles.pls")
# header
radio = rotate([jingles, radio.{weight = 4}])
# footer
output(radio)
