#!/usr/bin/env liquidsoap
s = normalize_track_gain(playlist(prefix="replaygain:", "~/Music"))
output(s)
