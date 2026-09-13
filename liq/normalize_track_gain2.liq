#!/usr/bin/env liquidsoap
# header
enable_replaygain_metadata()
s = normalize_track_gain(playlist("~/Music"))
# footer
output(s)
