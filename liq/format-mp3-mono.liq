#!/usr/bin/env liquidsoap
s = mksafe(playlist("~/Music"))
# header
output.file(%mp3(mono, bitrate=192), "/tmp/backup.mp3", s)
