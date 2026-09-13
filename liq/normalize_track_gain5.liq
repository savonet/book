#!/usr/bin/env liquidsoap
# header
s = normalize_track_gain(playlist(prefix="replaygain:", "~/Music"))
# footer
output(s)
