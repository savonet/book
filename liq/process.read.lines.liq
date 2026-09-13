#!/usr/bin/env liquidsoap
# header
p = process.read.lines("./generate-playlist")
s = playlist.list(p)
output(s)
