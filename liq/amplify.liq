#!/usr/bin/env liquidsoap
s = playlist("~/Music")
s = amplify(0.5, s)
output(s)
