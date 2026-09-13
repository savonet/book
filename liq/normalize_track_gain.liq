#!/usr/bin/env liquidsoap
# header
s = playlist("~/Music")
s = amplify(override="replaygain_track_gain", 1., s)
# footer
output(s)
