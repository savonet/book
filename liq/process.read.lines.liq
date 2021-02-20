#!/usr/bin/env liquidsoap
p = process.read.lines("./generate-playlist")
s = playlist.list(p)
output(s)
