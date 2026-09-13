#!/usr/bin/env liquidsoap
# header
enable_lufs_track_gain_metadata()
# footer
s = normalize_track_gain(playlist("~/Music"))
output(s)
