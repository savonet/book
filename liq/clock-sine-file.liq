#!/usr/bin/env liquidsoap
log.level := 5
s = sine()
output.file(%mp3, "/tmp/out.mp3", s)