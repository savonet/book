#!/usr/bin/env liquidsoap
s = replaygain(single("replaygain:test.mp3"))
output(s)
