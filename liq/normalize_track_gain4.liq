#!/usr/bin/env liquidsoap
s = normalize_track_gain(single("replaygain:test.mp3"))
output(s)
