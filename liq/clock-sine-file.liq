#!/usr/bin/env liquidsoap
log.level := 5
# header
s = sine()
output.file(%mp3, "/tmp/out.mp3", s)
