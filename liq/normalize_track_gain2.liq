#!/usr/bin/env liquidsoap
enable_replaygain_metadata()
s = normalize_track_gain(playlist("~/Music"))
output(s)
