#!/usr/bin/env liquidsoap
# header
s = single("video.mkv")
output.alsa(s)
output.sdl(s)
