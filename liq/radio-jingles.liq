#!/usr/bin/env liquidsoap
radio   = playlist("/radio/day.pls")
jingles = playlist("/radio/jingles.pls")
radio   = random([jingles, radio.{weight = 4}])
output(radio)
