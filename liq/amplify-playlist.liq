#!/usr/bin/env liquidsoap
s = playlist("~/Music")
s = amplify(0.8, s)
output(s)
