#!/usr/bin/env liquidsoap
s = playlist("~/Music")
# header
s = amplify(0.5, s)
# footer
output(s)
