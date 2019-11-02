#!/usr/bin/env liquidsoap
s = sine()
s = fallback(track_sensitive=false, [s, playlist.safe("~/Music/misc")])
output.pulseaudio(s)