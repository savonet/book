#!/usr/bin/env liquidsoap
s = playlist("~/Music")
s = amplify(lin_of_dB(4.), s)
output(s)
