#!/usr/bin/env liquidsoap
# header
s = playlist("~/Music")
s = amplify(0.8, s)
output(s)
