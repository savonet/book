#!/usr/bin/env liquidsoap
s = normalize_track_gain(playlist("~/Music"))
output(s)
