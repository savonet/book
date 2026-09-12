#!/usr/bin/env liquidsoap
enable_lufs_track_gain_metadata()
s = normalize_track_gain(playlist("~/Music"))
output(s)
