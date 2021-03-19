#!/usr/bin/env liquidsoap
log.level.set(5)
s = input.alsa()
s = amplify(0.8, s)
output.file(%mp3, "/tmp/out.mp3", s)