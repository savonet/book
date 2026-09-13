#!/usr/bin/env liquidsoap
s = playlist("~/Music")
# header
s = amplify(lin_of_dB(4.), s)
# footer
output(s)
