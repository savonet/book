#!/usr/bin/env liquidsoap
# header
s = normalize_track_gain(single("replaygain:test.mp3"))
# footer
output(s)
