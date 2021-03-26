#!/usr/bin/env liquidsoap
s = playlist("~/Music")
s = amplify(override="replaygain_track_gain", 1., s)
output(s)
