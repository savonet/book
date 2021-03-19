#!/usr/bin/env liquidsoap
log.level.set(5)
s = sine()
output.file(%mp3, "/tmp/out.mp3", s)