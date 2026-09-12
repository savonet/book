#!/usr/bin/env liquidsoap
s = single("video.mkv")
output.alsa(s)
output.sdl(s)
