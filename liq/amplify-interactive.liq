#!/usr/bin/env liquidsoap
s = playlist("~/Music")
a = interactive.float("main_volume", 1.)
s = amplify(a, s)
output(s)
