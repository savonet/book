#!/usr/bin/env liquidsoap
mic = input.alsa()
s = amplify(2., mic)
output(buffer(s))
